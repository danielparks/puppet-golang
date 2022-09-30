# @summary Install Go in a local directory
#
# @example Simple
#   golang::installation { '/usr/local/go': }
#
# @example For a user
#   golang::installation { '/home/user/go/go':
#     version => '1.10.4',
#     owner   => 'user',
#     group   => 'user',
#   }
#
# @param ensure
#   * `present`: Make sure Go is installed.
#   * `absent`: Make sure Go is uninstalled.
# @param go_dir
#   The path where Go should be installed. This path will be managed by
#   [`golang::from_tarball`](#golang--from_tarball).
# @param version
#   The version of Go to install. You can find the latest version number at
#   https://go.dev/dl/
# @param source_prefix
#   URL to directory that contains the archive to download.
# @param os
#   The OS to use to determine what archive to download.
# @param arch
#   The architecture to use to determine what archive to download.
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
#   match the URL we generate, then we know that we need to download the tarball
#   and replace the installation.
#
#   This defaults to a file in the same directory as `$go_dir`, but with a `.`
#   prefix and a `.source_url` suffix. For example, if `$go_dir` is
#   `'/usr/local/go'`, then this will default to `'/usr/local/.go.source_url'`.
define golang::installation (
  Enum[present, absent]          $ensure        = present,
  Stdlib::Unixpath               $go_dir        = $name,
  String[1]                      $version       = '1.19.1',
  Stdlib::HTTPUrl                $source_prefix = 'https://go.dev/dl',
  String[1]                      $os            = $facts['kernel'] ? {
    'Linux'  => 'linux',
    'Darwin' => 'darwin',
    default  => $facts['kernel'] # lint:ignore:parameter_documentation broken
  },
  String[1]                      $arch          = $facts['os']['hardware'] ? {
    undef     => 'amd64', # Assume amd64 if os.hardware is missing.
    'aarch64' => 'arm64',
    'armv7l'  => 'armv6l',
    'i686'    => '386',
    'x86_64'  => 'amd64',
    default   => $facts['os']['hardware'], # lint:ignore:parameter_documentation broken
  },
  Variant[String[1], Integer[0]] $owner         = $facts['identity']['user'],
  Variant[String[1], Integer[0]] $group         = $facts['identity']['group'],
  String[1]                      $mode          = '0755',
  Stdlib::Unixpath               $state_file    = golang::state_file($go_dir),
) {
  golang::from_tarball { $go_dir:
    ensure     => $ensure,
    source     => "${source_prefix}/go${version}.${os}-${arch}.tar.gz",
    owner      => $owner,
    group      => $group,
    mode       => $mode,
    state_file => $state_file,
  }
}
