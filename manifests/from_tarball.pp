# @summary Install Go from a binary tarball
#
# @example Standard usage
#   golang::from_tarball { '/usr/local/go':
#     source => 'https://go.dev/dl/go1.19.1.darwin-amd64.tar.gz',
#   }
#
# @example Running puppet as `user`
#   golang::from_tarball { '/home/user/go/go':
#     source => 'https://go.dev/dl/go1.19.1.darwin-amd64.tar.gz',
#   }
#
# @param source
#   The URL to the binary tarball to install. If the URL changes and `$ensure`
#   is `present`, `$go_dir` will be wiped and the new tarball will be installed.
# @param ensure
#   * `present`: Make sure Go is installed from `$source`.
#   * `any_version`: Make sure Go is installed regardless of what version it is.
#     This will not upgrade Go if `$source` changes.
#   * `absent`: Make sure Go is uninstalled.
# @param go_dir
#   The path where the tarball should be installed. This path will be managed
#   by this resource.
# @param owner
#   The user that should own `$go_dir`. May be a user name or a UID.
# @param group
#   The group that should own `$go_dir`. May be a group name or a GID.
# @param mode
#   The mode for `$go_dir`.
# @param state_file
#   Where to store state information.
#
#   This file will contain the URL to the tarball. If the file contents don’t
#   match the URL passed in `$source`, then we know that we need to download the
#   tarball and replace the installation.
#
#   This defaults to a file in the same directory as `$go_dir`, but with a `.`
#   prefix and a `.source_url` suffix. For example, if `$go_dir` is
#   `'/usr/local/go'`, then this will default to `'/usr/local/.go.source_url'`.
define golang::from_tarball (
  Stdlib::HTTPUrl                    $source,
  Enum[present, any_version, absent] $ensure     = present,
  Stdlib::Unixpath                   $go_dir     = $name,
  Variant[String[1], Integer[0]]     $owner      = $facts['identity']['user'],
  Variant[String[1], Integer[0]]     $group      = $facts['identity']['group'],
  String[1]                          $mode       = '0755',
  Stdlib::Unixpath                   $state_file = golang::state_file($go_dir),
) {
  if $ensure != any_version {
    # Used to ensure that the installation is updated when $source changes.
    $file_ensure = $ensure ? {
      'present' => file,
      'absent'  => absent,
    }

    file { $state_file:
      ensure  => $file_ensure,
      owner   => $owner,
      group   => $group,
      mode    => '0444',
      # lint:ignore:strict_indent broken lint check
      content => @("EOF"),
        # This file is managed by Puppet.
        #
        # Any changes will cause Go to be reinstalled on the next Puppet run and
        # this file to be overwritten.
        ${source}
        | EOF
      # lint:endignore
    }
  }

  $directory_ensure = $ensure ? {
    'present'     => directory,
    'any_version' => directory,
    'absent'      => absent,
  }

  file { $go_dir:
    ensure => $directory_ensure,
    force  => true,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }

  if $ensure == present or $ensure == any_version {
    $encoded_go_dir = $go_dir.regsubst('/', '_', 'G')
    $archive_path = "/tmp/puppet-golang${encoded_go_dir}.tar.gz"

    # Only trigger an update when ensure is present, and not any_version.
    if $ensure == present {
      # If the $go_dir/bin directory exists, archive won't update it. Also, we
      # want to remove any files that are not present in the new version.
      exec { "dp/golang refresh go installation at ${go_dir}":
        command     => ['rm', '-rf', $go_dir],
        path        => ['/usr/local/bin', '/usr/bin', '/bin'],
        user        => $facts['identity']['user'],
        refreshonly => true,
        subscribe   => File[$state_file],
        before      => File[$go_dir],
        notify      => Archive[$archive_path],
      }
    }

    include archive

    archive { $archive_path:
      ensure        => present,
      extract       => true,
      extract_path  => $go_dir,
      extract_flags => '--strip-components 1 --no-same-owner --no-same-permissions -xf',
      user          => $owner,
      group         => $group,
      source        => $source,
      creates       => "${go_dir}/bin",
      cleanup       => true,
      require       => File[$go_dir],
    }
  }
}
