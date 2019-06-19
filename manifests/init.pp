# Install go in /usr/local/go and /usr/local/bin
#
# Most people will not need to change any parameter other than `$version`.
class golang (
  String[1]        $version       = '1.11',
  Array[String[1]] $link_binaries = ['go', 'gofmt', 'godoc'],
  String[1]        $archive_path  = '/usr/local/src/puppet-golang.tar.gz',
  String[1]        $source_prefix = 'https://dl.google.com/go',
  String[1]        $source        = "${source_prefix}/go${version}.${os}-${arch}.tar.gz",
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
) {
  $archive_directory = regsubst($archive_path, '/[^/]+\Z', '')
  if ! defined(File[$archive_directory]) {
    file { $archive_directory:
      ensure => directory,
      owner  => 0,
      group  => 0, # root's group, whether it's called "root" or "wheel"
    }
  }

  # Download the archive
  file { $archive_path:
    ensure => file,
    owner  => 0,
    group  => 0, # root's group, whether it's called "root" or "wheel"
    source => "https://dl.google.com/go/go${version}.linux-amd64.tar.gz",
    notify => Exec['golang: extract and install'],
  }

  # This first uninstalls the old version of go if present.
  exec { 'golang: extract and install':
    command => "rm -rf go ; tar -xzf '${archive_path}'",
    cwd     => '/usr/local',
    path    => ['/usr/local/bin', '/usr/bin', '/bin'],
    user    => 'root',
    creates => '/usr/local/go',
  }

  $link_binaries.each |$binary| {
    file { "/usr/local/bin/${binary}":
      ensure => link,
      target => "/usr/local/go/bin/${binary}",
    }
  }
}
