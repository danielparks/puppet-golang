# golang

This installs go under `/usr/local/go/`, and symlinks the binaries into
`/usr/local/bin/`.

## Usage

~~~ puppet
include golang
~~~

You may wish to set the version with hiera (`golang::version: 1.10.4`), or in
a class declaration:

~~~ puppet
class { 'golang':
  version => '1.10.4',
}
~~~

### Notes

This will attempt to create `/usr/local/src`, and it will store the golang
archive in that directory.

## Limitations

This does not support Windows.
