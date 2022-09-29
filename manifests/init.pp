# @summary Install go in `/usr/local/go` and `/usr/local/bin`
#
# `/usr/local/share/` *must* exist.
#
# Most people will not need to change any parameter other than `$version`.
#
# @param ensure
#   * `present`: Make sure go is installed.
#   * `absent`: Make sure go is uninstalled.
# @param version
#   The version of Go to install. You can find the latest version number at
#   https://go.dev/dl/
# @param link_binaries
#   The binaries to symlink into `/usr/local/bin`.
# @param source_prefix
#   URL to directory that contains the archive to download.
# @param os
#   The OS to use to determine what archive to download.
# @param arch
#   The architecture to use to determine what archive to download.
# @param source
#   URL to actual archive.
class golang (
  Enum[present, absent] $ensure        = present,
  String[1]             $version       = '1.19.1',
  Array[String[1]]      $link_binaries = ['go', 'gofmt'],
  Stdlib::HTTPUrl       $source_prefix = 'https://go.dev/dl',
  String[1]             $os            = $facts['kernel'] ? {
    'Linux'  => 'linux',
    'Darwin' => 'darwin',
    default  => $facts['kernel'] # lint:ignore:parameter_documentation broken
  },
  String[1]             $arch          = $facts['os']['hardware'] ? {
    undef     => 'amd64', # Assume amd64 if os.hardware is missing.
    'aarch64' => 'arm64',
    'armv7l'  => 'armv6l',
    'i686'    => '386',
    'x86_64'  => 'amd64',
    default   => $facts['os']['hardware'], # lint:ignore:parameter_documentation broken
  },
  Stdlib::HTTPUrl       $source        = "${source_prefix}/go${version}.${os}-${arch}.tar.gz",
) {
  golang::from_tarball { '/usr/local/go':
    ensure => $ensure,
    source => $source,
  }

  $link_ensure = $ensure ? {
    'present' => link,
    default   => absent,
  }

  $link_binaries.each |$binary| {
    file { "/usr/local/bin/${binary}":
      ensure  => $link_ensure,
      target  => "/usr/local/go/bin/${binary}",
      require => Golang::From_tarball['/usr/local/go'],
    }
  }
}
