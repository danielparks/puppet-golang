# Easily install and update Go

## Usage

### Standard, single install

This installs Go under `/usr/local/go/`, and symlinks the binaries into
`/usr/local/bin/`.

``` puppet
include golang
```

You may wish to set the version with hiera (`golang::version: 1.10.4`), or with
a class declaration:

``` puppet
class { 'golang':
  version => '1.10.4',
}
```

To uninstall Go, just do:

``` puppet
class { 'golang':
  ensure => absent,
}
```

### Multiple installs

You can install Go in other places and as other users using the
`golang::installation` defined type:

``` puppet
golang::installation { '/home/user/go-1.10.4':
  version => '1.10.4',
  owner   => 'user',
  group   => 'user',
}

golang::linked_binaries { '/home/user/go-1.10.4':
  into_bin => '/home/user/bin',
}
```

Of course, you can remove these resources with `ensure => absent`.

### Running Puppet as a non-root user

You can use the defined types to install Go even when running as a non-root
user. `owner` and `group` default to the user and group running Puppet:

``` puppet
golang::installation { '/home/me/go-1.10.4':
  version => '1.10.4',
}

golang::linked_binaries { '/home/me/go-1.10.4':
  into_bin => '/home/me/bin',
}
```

## Limitations

This does not support Windows.

## Reference

There is specific documentation for individual parameters in
[REFERENCE.md](REFERENCE.md). That file is generated with:

```
pdk bundle exec puppet strings generate --format markdown
```
