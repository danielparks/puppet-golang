# Simple yet flexible Go installations

This [Puppet][] module has sane defaults to keep a standard installation simple,
but is flexible enough to support automatic updates, multiple installations of
diferent versions, and running [Puppet as a non-root user][non-root].

[Puppet]: https://github.com/puppetlabs/puppet
[non-root]: #running-puppet-as-a-non-root-user

## Usage

### Standard, single install

The [`golang` class][`golang`] installs Go under `/usr/local/go/`, and symlinks
the binaries into `/usr/local/bin/`.

``` puppet
include golang
```

By default it installs the latest version but never upgrades it after the
initial installation. You can set it to automatically upgrade by passing
`latest` to [`ensure`][$golang::ensure], either with [hiera][]
(`golang::ensure: latest`), or with a class declaration:

``` puppet
class { 'golang':
  ensure => latest,
}
```

You may force it to install a specific version by passing it to
[`ensure`][$golang::ensure]:

``` puppet
class { 'golang':
  ensure => '1.19.1',
}
```

Of course, you can also use [`ensure`][$golang::ensure] to uninstall Go:

``` puppet
class { 'golang':
  ensure => absent,
}
```

### Multiple installs

You can install Go in other places and as other users using the
[`golang::installation`][] defined type, and you can link its binaries into
a `bin` directory with [`golang::linked_binaries`][]:

``` puppet
golang::installation { '/home/user/go-1.19.1':
  ensure => '1.19.1',
  owner  => 'user',
  group  => 'user',
}

golang::linked_binaries { '/home/user/go-1.19.1':
  into_bin => '/home/user/bin',
}
```

To install the latest version, set [`ensure => latest`][$g::i::ensure] on
[`golang::installation`][]. To remove the installation or symlinks, just use
`ensure => absent`.

### Running Puppet as a non-root user

You can use the defined types to install Go even when running as a non-root
user. [`owner`][$g::i::owner] and [`group`][$g::i::group] default to the user
and group running Puppet:

``` puppet
golang::installation { '/home/me/go':
  ensure => latest,
}

golang::linked_binaries { '/home/me/go':
  into_bin => '/home/me/bin',
}
```

## Limitations

This does not support Windows.

## Development status

This is stable. I have no features planned for the future, though I’m open to
[suggestions][issues].

I will occasionally make 0.0.1 releases to keep this updated with the latest
version of [PDK][].

## Reference

There is specific documentation for individual parameters in [REFERENCE.md][].
That file is generated with:

```
pdk bundle exec puppet strings generate --format markdown
```

[`golang`]: REFERENCE.md#golang
[$golang::ensure]: REFERENCE.md#-golang--ensure
[`golang::installation`]: REFERENCE.md#golang--installation
[$g::i::ensure]: REFERENCE.md#-golang--installation--ensure
[$g::i::owner]: REFERENCE.md#-golang--installation--owner
[$g::i::group]: REFERENCE.md#-golang--installation--group
[`golang::linked_binaries`]: REFERENCE.md#golang--linked_binaries
[hiera]: https://puppet.com/docs/puppet/latest/hiera.html
[issues]: https://github.com/danielparks/puppet-golang/issues
[PDK]: https://github.com/puppetlabs/pdk
[REFERENCE.md]: REFERENCE.md
