#!/usr/bin/env ruby

# rubocop:disable Style/WhileUntilModifier

require 'getoptlong'
require 'json'
require 'open3'
require 'rdoc'
require 'shellwords'
require 'uri'

def usage
  <<~'TEXT'
    ./release.rb [--forge-token TOKEN] [options...] VERSION SUMMARY

      Make a release.

      VERSION   the version to release. Will be set in metadata.json
      SUMMARY   the one line summary of the release

      --forge-token TOKEN  may be left off if $PDK_FORGE_TOKEN is set
      --dry-run            don’t commit or publish any changes
      --just-forge-update  just update files as if we were going to build a
                           package to upload to the Forge
      --no-acceptance      skip acceptance tests
      --no-unit            skip unit tests

    ./release.rb --help

      Show this help.
  TEXT
end

def usage_error(message)
  STDERR.puts message
  STDERR.puts
  STDERR.print usage
  exit 1
end

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--dry-run', '-n', GetoptLong::NO_ARGUMENT ],
  [ '--forge-token', '-t', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--just-forge-update', GetoptLong::NO_ARGUMENT ],
  [ '--no-acceptance', GetoptLong::NO_ARGUMENT ],
  [ '--no-unit', GetoptLong::NO_ARGUMENT ],
)

forge_token = ENV['PDK_FORGE_TOKEN']
dry_run = false
just_forge_update = false
run_acceptance = run_unit = true

opts.each do |opt, arg|
  case opt
  when '--help'
    print usage
    exit 0
  when '--forge-token'
    forge_token = arg
  when '--dry-run'
    dry_run = true
  when '--just-forge-update'
    just_forge_update = true
  when '--no-acceptance'
    run_acceptance = false
  when '--no-unit'
    run_unit = false
  end
end

if ARGV.length != 2
  usage_error "Missing arguments.\n"
end

version, summary = ARGV

if forge_token.nil? || forge_token.empty?
  usage_error 'Must specify TOKEN (use $PDK_FORGE_TOKEN environment variable)'
end

# Modifies CHANGELOG.md for release and extracts changes
#
# changelog should be an array of lines
def extract_changes_for_release!(changelog, version)
  release_notes = []

  begin
    enumerator = changelog.to_enum
    line = enumerator.next
    until line.match?(%r{\A##[^#]})
      # Skip everything up to the first level 2 heading
      line = enumerator.next
    end

    # Should have found "## main branch". Replace it with "## Release..."
    line.replace("## Release #{version}\n")

    line = enumerator.next
    while line.match?(%r{\A\s*\z})
      # Skip blank lines
      line = enumerator.next
    end

    # Collect everything up to next "## Release..." line
    until line.match?(%r{\A##[^#]})
      release_notes << line
      line = enumerator.next
    end
  rescue StopIteration
    # We ran out of file; doesn’t matter
  end

  # Trim blank lines off end of release notes
  while %r{\A\s*\z}.match?(release_notes.last)
    release_notes.pop
  end

  release_notes.join('')
end

# Add "## main branch" back to CHANGELOG.md
def insert_main_branch_header!(changelog)
  enumerator = changelog.to_enum
  line = enumerator.next
  until line.match?(%r{\A##[^#]})
    # Skip everything up to the first level 2 heading
    line = enumerator.next
  end

  # Should have found the first Release header. Insert the main branch header
  # and a blank line.
  line.insert(0, "## main branch\n\n")
end

def fix_links(root, path)
  puts "Fixing links in #{path} for Forge"
  lines = IO.readlines(path).map do |line|
    if (match = line.match(%r{\A\[(.+?)\]:\s*(.+)\Z}))
      # A link destination on its own line ("[name]: url" syntax)
      name = match[1]
      uri = URI(match[2])

      unless uri.absolute? || !uri.host.nil? || uri.path.empty?
        uri = root + uri
      end

      "[#{name}]: #{uri}\n"
    else
      line
    end
  end

  IO.write(path, lines.join(''))
end

# Huge kludge. Only works on unorderd lists at the moment.
def unwrap_markdown!(md)
  while md.gsub!(%r{^( *)([*+-])( +\S.+?)\n\1  +([^ *+-])}, '\1\2\3 \4')
  end
end

def update_metadata(version)
  puts "Updating metadata.json with version #{version}"
  metadata = IO.read('metadata.json')
  metadata.sub!(%r{("version"\s*:\s*)"[0-9.]+"}, %(\\1"#{version}"))
  IO.write('metadata.json', metadata)
end

# Update files for the Forge
def update_for_forge(metadata)
  root_uri = URI("#{metadata['source']}/blob/v#{metadata['version']}/")
  Dir['*.md'].each do |file|
    fix_links(root_uri, file)
  end
end

def run(command, *args, dry_run: false)
  shell_args = args.map { |word| Shellwords.escape(word) }.join(' ')
  if dry_run
    puts "SKIPPING: #{command} #{shell_args}"
    return
  end

  puts "#{command} #{shell_args}"
  case system(command, *args)
  when nil
    raise "Command #{command} not found"
  when false
    raise "Command returned non-zero: #{command} #{shell_args}"
  end
end

def run_capture(command, *args, dry_run: false)
  shell_args = args.map { |word| Shellwords.escape(word) }.join(' ')
  if dry_run
    puts "SKIPPING: #{command} #{shell_args}"
    return ''
  end

  puts "#{command} #{shell_args}"
  output, status = Open3.capture2e(command, *args)
  unless status.success?
    raise "Command returned non-zero: #{command} #{shell_args}"
  end

  output
end

def confirm_no_changes
  untracked = run_capture('git', 'ls-files', '--exclude-standard', '--other')
  unless untracked == ''
    puts untracked
    raise 'Found untracked files.'
  end

  run('git', 'diff', '--color', '--exit-code')
end

# There are broadly three passes to this.
#
#   1. Generate changes to the repo that reflect a release.
#
#      This includes adding the release version to CHANGELOG.md and
#      metadata.json, tagging the commit, etc.
#
#   2. Generate the release artifact and publish it.
#
#      Munge all the Markdown files to use links that work on Forge. This will
#      not commit anything. When it’s done, all changed files must be restored
#      to the committed versions.
#
#   3. Generate changes to the repo the reflect development.
#
#      Add "## main branch" back to CHANGELOG.md.

confirm_no_changes

# Update CHANGELOG.md for release and extra the changes for the release
changelog = IO.readlines('CHANGELOG.md')
release_notes = extract_changes_for_release!(changelog, version)
puts "Updating CHANGELOG.md with release #{version}"
File.write('CHANGELOG.md', changelog.join(''))

update_metadata(version)
metadata = JSON.parse(File.read('metadata.json'))

if just_forge_update
  update_for_forge(metadata)
  exit(0)
end

run('git', 'add', 'CHANGELOG.md', 'metadata.json')

puts 'Confirming that REFERENCE.md is up-to-date'
run('pdk', 'bundle', 'exec', 'puppet', 'strings', 'generate',
  '--format', 'markdown')
confirm_no_changes

puts 'Confirming that pdk update does nothing'
run('pdk', 'update', '--force')
confirm_no_changes

run('pdk', 'validate')

if run_unit
  run('pdk', 'test', 'unit')
end

if run_acceptance && File.exist?('spec/acceptance')
  run('./test.sh', 'init', 'run', 'destroy')
end

run('git', 'commit', '-m', "Release #{version}: #{summary.chomp('.')}.",
  dry_run: dry_run)
run('git', 'tag', "v#{version}", '-sm', <<~MSG.chomp, dry_run: dry_run)
  #{version}: #{summary}

  #{release_notes}
MSG

update_for_forge(metadata)

run('pdk', 'build', '--force')
run('pdk', 'release', 'publish', dry_run: dry_run)

# Reset Forge-specific changes
run('git', 'restore', '.', dry_run: dry_run)

# Add "## main branch" header to CHANGELOG.md
insert_main_branch_header!(changelog)
puts 'Updating CHANGELOG.md with main branch header'
File.write('CHANGELOG.md', changelog.join(''))

run('git', 'add', 'CHANGELOG.md')
run('git', 'commit', '-m', 'Add “## main branch” header back to CHANGELOG.md.',
  dry_run: dry_run)

# Push release to GitHub
run('git', 'push', '--tags', 'origin', 'main', dry_run: dry_run)

unwrap_markdown!(release_notes)

run('gh', 'release', 'create',
  '--title', "#{version}: #{summary}",
  '--notes', release_notes,
  "v#{version}",
  Dir["pkg/*-#{version}.tar.gz"].first,
  dry_run: dry_run)
