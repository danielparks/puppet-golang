# @summary Install go in `/usr/local/go` and `/usr/local/bin`
#
# Most people will not need to change any parameter other than perhaps setting
# `$ensure` to `latest`.
#
# @param ensure
#   * `present`: Make sure any version of Go is installed.
#   * `latest`: Make sure the latest stable version of Go is installed.
#   * `absent`: Make sure Go is uninstalled.
#   * _version_: Make sure exactly the specified version of Go is installed.
#     For example, `'1.19.1'`.
# @param version
#   **Deprecated.** Use `$ensure` instead. If this parameter is set it will only
#   be honored if `$ensure` is `present`.
# @param link_binaries
#   The binaries to symlink into `/usr/local/bin`.
# @param source_prefix
#   URL to directory that contains the archive to download.
# @param os
#   The OS to use to determine what archive to download.
# @param arch
#   The architecture to use to determine what archive to download.
# @param source
#   **Deprecated.** Use `golang::from_tarball` instead:
#
#   ```puppet
#   golang::from_tarball { '/usr/local/go':
#     ensure => $ensure,
#     source => $source,
#   }
#
#   golang::linked_binaries { '/usr/local/go':
#     ensure   => $ensure,
#     into_bin => '/usr/local/bin',
#   }
#   ```
#
#   If this is set it overrides everything else except `$ensure == absent`.
class golang (
  Golang::Ensure            $ensure        = present,
  Optional[Golang::Version] $version       = undef,
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
  if $version {
    # lint:ignore:strict_indent broken
    deprecation(
      '$golang::version',
      'The $version parameter on golang is deprecated; use $ensure instead.')
    # lint:endignore
  }

  if $source == undef {
    if $version {
      $installation_ensure = $ensure ? {
        'present' => $version,
        default   => $ensure
      }
    } else {
      $installation_ensure = $ensure
    }

    golang::installation { '/usr/local/go':
      ensure        => $installation_ensure,
      source_prefix => $source_prefix,
      os            => $os,
      arch          => $arch,
    }
  } else {
    # lint:ignore:strict_indent broken
    deprecation(
      '$golang::source',
      'The $source parameter on golang is deprecated; use golang::from_tarball instead.')
    # lint:endignore

    $tarball_ensure = $ensure ? {
      'absent' => absent,
      default  => present,
    }

    golang::from_tarball { '/usr/local/go':
      ensure => $tarball_ensure,
      source => $source,
    }
  }

  $linked_ensure = $ensure ? {
    'absent' => absent,
    default  => present,
  }

  golang::linked_binaries { '/usr/local/go':
    ensure   => $linked_ensure,
    into_bin => '/usr/local/bin',
    binaries => $link_binaries,
  }
}
