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
  $archive_path = '/tmp/puppet-golang.tar.gz'

  $file_ensure = $ensure ? {
    'present' => file,
    default   => absent,
  }
  $link_ensure = $ensure ? {
    'present' => link,
    default   => absent,
  }

  include archive

  # Used to ensure that the installation is updated when $source changes.
  file { '/usr/local/share/go-SOURCE':
    ensure  => $file_ensure,
    owner   => 0,
    group   => 0, # group might be called root or wheel
    mode    => '0644',
    # lint:ignore:strict_indent broken lint check
    content => @("EOF"),
      # This file is managed by Puppet. Changes will be overwritten.
      ${source}
      | EOF
    # lint:endignore
  }

  if $ensure == present {
    # If the /usr/local/go directory exists, archive won't update it.
    exec { 'dp/golang refresh go installation':
      command     => 'rm -rf /usr/local/go',
      path        => ['/usr/local/bin', '/usr/bin', '/bin'],
      user        => 'root',
      refreshonly => true,
      subscribe   => File['/usr/local/share/go-SOURCE'],
      notify      => Archive[$archive_path],
    }
  } else {
    file { '/usr/local/go':
      ensure => absent,
      force  => true,
    }
  }

  archive { $archive_path:
    ensure       => $ensure,
    extract      => true,
    extract_path => '/usr/local',
    source       => $source,
    creates      => '/usr/local/go',
    cleanup      => true,
  }

  $link_binaries.each |$binary| {
    file { "/usr/local/bin/${binary}":
      ensure  => $link_ensure,
      target  => "/usr/local/go/bin/${binary}",
      require => Archive[$archive_path],
    }
  }
}
