# @summary Link binaries from Go installation into a directory
#
# @example Standard usage
#   golang::linked_binaries { '/usr/local/go':
#     into_bin => '/usr/local/bin',
#   }
#
# @example User install
#   golang::linked_binaries { '/home/user/go/go':
#     into_bin => '/home/user/bin',
#   }
#
# @param into_bin
#   The directory to link the binaries into.
# @param ensure
#   * `present`: Make sure links are present.
#   * `absent`: Make sure links are absent.
# @param go_dir
#   The directory where Go is installed.
# @param binaries
#   The binaries to link.
define golang::linked_binaries (
  Stdlib::Unixpath      $into_bin,
  Enum[present, absent] $ensure   = present,
  Stdlib::Unixpath      $go_dir   = $name,
  Array[String[1]]      $binaries = ['go', 'gofmt'],
) {
  $link_ensure = $ensure ? {
    'present' => link,
    default   => absent,
  }

  $binaries.each |$binary| {
    file { "${into_bin}/${binary}":
      ensure  => $link_ensure,
      target  => "${go_dir}/bin/${binary}",
      require => Golang::From_tarball[$go_dir],
    }
  }
}
