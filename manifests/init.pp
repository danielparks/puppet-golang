# @summary Install go in `/usr/local/go` and `/usr/local/bin`
#
# Most people will not need to change any parameter other than `$version`.
#
# @param ensure
#   * `present`: Make sure Go is installed.
#   * `absent`: Make sure Go is uninstalled.
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
#   URL of a binary tarball. If this is set it overrides everything else.
class golang (
  Enum[present, absent]     $ensure        = present,
  String[1]                 $version       = '1.19.1',
  Array[String[1]]          $link_binaries = ['go', 'gofmt'],
  Stdlib::HTTPUrl           $source_prefix = 'https://go.dev/dl',
  String[1]                 $os            = $facts['kernel'] ? {
    'Linux'  => 'linux',
    'Darwin' => 'darwin',
    default  => $facts['kernel'] # lint:ignore:parameter_documentation broken
  },
  String[1]                 $arch          = $facts['os']['hardware'] ? {
    undef     => 'amd64', # Assume amd64 if os.hardware is missing.
    'aarch64' => 'arm64',
    'armv7l'  => 'armv6l',
    'i686'    => '386',
    'x86_64'  => 'amd64',
    default   => $facts['os']['hardware'], # lint:ignore:parameter_documentation broken
  },
  Optional[Stdlib::HTTPUrl] $source        = undef,
) {
  if $source == undef {
    golang::installation { '/usr/local/go':
      ensure        => $ensure,
      version       => $version,
      source_prefix => $source_prefix,
      os            => $os,
      arch          => $arch,
    }
  } else {
    golang::from_tarball { '/usr/local/go':
      ensure => $ensure,
      source => $source,
    }
  }

  golang::linked_binaries { '/usr/local/go':
    ensure   => $ensure,
    into_bin => '/usr/local/bin',
    binaries => $link_binaries,
  }
}
