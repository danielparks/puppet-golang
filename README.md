# golang

This installs go under `/usr/local/go/`, and symlinks the binaries into
`/usr/local/bin/`.

## Usage

~~~ puppet
include golang
~~~

You may wish to set the version with hiera (`golang::version: 1.10.4`), or with
a class declaration:

~~~ puppet
class { 'golang':
  version => '1.10.4',
}
~~~

## Limitations

This does not support Windows.

## Reference

There is specific documentation for individual parameters in
[REFERENCE.md](REFERENCE.md). That file is generated with:

~~~
pdk bundle exec puppet strings generate --format markdown
~~~
