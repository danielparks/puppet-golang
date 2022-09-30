# Change log

All notable changes to this project will be documented in this file.

## main branch

### Features

* Added `golang::installation` to allow multiple installs on the same system.
  Installations can be owned by root or any other user.
* Added `golang::linked_binaries` link binaries from a Go installation into a
  `bin` directory.

### Improvements

* Added `golang::from_tarball` to explicitly install Go from a binary tarball.
  This can be used to make multiple installations as root or non-root users.
* Use [`Stdlib::HTTPUrl`][] data type for URL parameters.

[`Stdlib::HTTPUrl`]: https://github.com/puppetlabs/puppetlabs-stdlib/blob/0f032a9bc557949169f565bf41e5aa1f35b17346/REFERENCE.md#stdlibhttpurl

### Bug fixes

* Updated minimum Puppet version to match puppet/archive. [archive version
  4.0.0][https://forge.puppet.com/modules/puppet/archive/4.0.0] requires Puppet
  5.5.8 or higher, so this module must as well.

## Release 1.1.0

### Features

* Added `ensure` parameter to allow uninstalling Go.

### Bug fixes

* Used pre-release version of Puppet Strings to (mostly) fix parameter default
  values in [REFERENCE.md](REFERENCE.md).

## Release 1.0.7

### Features

* Latest Go version (1.19.1) installed by default.

## Release 1.0.6

### Bug fixes

* Updated change log.

## Release 1.0.5 (withdrawn)

### Features

* Latest Go version (1.18.3) installed by default.

### Bug fixes

* Updated to use the current Go domain (golang.org → go.dev).
* Metadata updated to support the most recent version of
  [puppet/archive](https://forge.puppet.com/modules/puppet/archive).

## Release 1.0.4

### Features

* Latest Go version (1.16.7) installed by default.

### Bug fixes

* The `godoc` binary no longer ships in the Go package, so this no longer links
  it into `/usr/local/bin` by default. **Note:** this does not remove the link
  if it already exists.
* Metadata updated to support the most recent version of
  [puppet/archive](https://forge.puppet.com/modules/puppet/archive).

## Release 1.0.3

### Features

* [#2](https://github.com/danielparks/puppet-golang/issues/2): support
  convenient installation on Raspberry Pi 2B and 3B.

### Bug fixes

* [#2](https://github.com/danielparks/puppet-golang/issues/2): default to the
  correct 64-bit ARM binary on 64 bit ARM, e.g. on the Raspberry Pi 4.

## Release 1.0.2

### Features

* Latest Go version (1.13.6) installed by default.
* [#2](https://github.com/danielparks/puppet-golang/issues/2): support
  convenient installation on Raspberry Pi 4.
