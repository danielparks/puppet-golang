# @summary Install go in /usr/local/go and /usr/local/bin
#
# `/usr/local/share/` *must* exist.
#
# Most people will not need to change any parameter other than `$version`.
#
# @param version
#   The version of Go to install. You can find the latest version number at
#   https://go.dev/dl/
# @param link_binaries
#   The binaries to symlink into `/usr/local/bin`.
# @param source
#   URL to actual archive.
# @param source_prefix
#   URL to directory that contains the archive to download.
# @param os
#   The OS to use to determine what archive to download.
# @param arch
#   The architecture to use to determine what archive to download.
class golang (
  String[1]        $version       = '1.16.7',
  Array[String[1]] $link_binaries = ['go', 'gofmt'],
  String[1]        $source_prefix = 'https://go.dev/dl',
  String[1]        $os            = $facts['kernel'] ? {
    'Linux'  => 'linux',
    'Darwin' => 'darwin',
    default  => $facts['kernel']
  },
  String[1]        $arch          = $facts['os']['hardware'] ? {
    undef     => 'amd64', # Assume amd64 if os.hardware is missing.
    'aarch64' => 'arm64',
    'armv7l'  => 'armv6l',
    'i686'    => '386',
    'x86_64'  => 'amd64',
    default   => $facts['os']['hardware'],
  },
  String[1]        $source        = "${source_prefix}/go${version}.${os}-${arch}.tar.gz",
) {
  $archive_path = '/tmp/puppet-golang.tar.gz'

  include archive

  # Used to ensure that the installation is updated when $source changes.
  file { '/usr/local/share/go-SOURCE':
    ensure  => file,
    owner   => 0,
    group   => 0, # group might be called root or wheel
    mode    => '0644',
    content => @("EOF"),
      # This file is managed by Puppet. Changes will be overwritten.
      ${source}
      | EOF
    notify  => Exec['dp/golang refresh go installation'],
  }

  # If the /usr/local/go directory exists, archive won't update it.
  exec { 'dp/golang refresh go installation':
    command     => 'rm -rf /usr/local/go',
    path        => ['/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'root',
    refreshonly => true,
    notify      => Archive[$archive_path],
  }

  archive { $archive_path:
    ensure       => present,
    extract      => true,
    extract_path => '/usr/local',
    source       => $source,
    creates      => '/usr/local/go',
    cleanup      => true,
  }

  $link_binaries.each |$binary| {
    file { "/usr/local/bin/${binary}":
      ensure  => link,
      target  => "/usr/local/go/bin/${binary}",
      require => Archive[$archive_path],
    }
  }
}
