# @summary Figure out the default state file path for a given `$go_dir`
#
# The location must be outside of `$go_dir`, and it must be writable by the
# same user (if Puppet is not being run as root).
#
# @param go_dir
#   Where Go will be installed
# @return [Stdlib::Absolutepath]
#   Where to store the state file by default
# @raise Puppet::Error
#   If `$go_dir` is `'/'` or a few other things, this will fail because there
#   isn’t a reasonable default outside of `$go_dir` itself.
function golang::state_file(Stdlib::Absolutepath $go_dir)
>> Stdlib::Absolutepath {
  $base = basename($go_dir)
  $dir = dirname($go_dir)

  if $base == '/' or $base == '.' or $base == '..' {
    fail("No reasonable default state_file for go_dir '${go_dir}'")
  } elsif $dir == '/' {
    "/.${base}.source_url"
  } else {
    "${dir}/.${base}.source_url"
  }
}
