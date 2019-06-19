# @summary Install go in /usr/local/go and /usr/local/bin
#
# This installs go under `/usr/local/go/` and symlinks the binaries into
# `/usr/local/bin/`.
#
# Most people will not need to change any parameter other than `$version`.
#
# @param version
#   The version of Go to install. You can find the latest version number at
#   https://golang.org/dl/
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
  String[1]        $version       = '1.12.6',
  Array[String[1]] $link_binaries = ['go', 'gofmt', 'godoc'],
  String[1]        $source_prefix = 'https://dl.google.com/go',
  String[1]        $os            = $facts['kernel'] ? {
    'Linux'  => 'linux',
    'Darwin' => 'darwin',
    default  => $facts['kernel']
  },
  String[1]        $arch          = $facts['os']['hardware'] ? {
    undef    => 'amd64', # Darwin doesn't have os.hardware.
    'x86_64' => 'amd64',
    'i686'   => '386',
    default  => $facts['os']['hardware'],
  },
  String[1]        $source        = "${source_prefix}/go${version}.${os}-${arch}.tar.gz",
) {
  include archive

  $archive_path = '/tmp/puppet-golang.tar.gz'
  archive { $archive_path:
    ensure          => present,
    extract         => true,
    extract_path    => '/usr/local',
    extract_command => 'rm -rf go && tar xzf %s',
    source          => $source,
    creates         => '/usr/local/go',
    cleanup         => true,
  }

  $link_binaries.each |$binary| {
    file { "/usr/local/bin/${binary}":
      ensure  => link,
      target  => "/usr/local/go/bin/${binary}",
      require => Archive[$archive_path],
    }
  }
}
