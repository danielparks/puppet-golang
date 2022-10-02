# Change log

All notable changes to this project will be documented in this file.

## main branch

### Bug fixes

* Fix in-page anchor link in [README.md][].

[README.md]: README.md

## Release 1.2.1

### Improvements

* Added more links to [REFERENCE.md][] from [README.md][] to make it easier to
  find reference documentation.

### Bug fixes

* Anchor links seem to be broken on the Forge, so we now update links to
  [REFERENCE.md][] and other markdown files to point to GitHub when making a
  release.
* The Hiera example in [README.md][] referenced the deprecated `golang::version`
  instead of `golang::ensure`.

[README.md]: README.md
[REFERENCE.md]: REFERENCE.md

## Release 1.2.0

### Features

* Added option of [`ensure => latest`][$golang::ensure] to automatically keep Go
  installations at the latest stable version.
* Added [`golang::installation`][] to allow multiple installs of standard Go
  packages from https://go.dev/dl on the same system. Installations can be owned
  by any user.
* Added [`golang::from_tarball`][] to explicitly install from a binary tarball.
* Added [`golang::linked_binaries`][] link binaries from a Go installation into
  a `bin` directory.

### Improvements

* Use [`Stdlib::HTTPUrl`][] data type for URL parameters.

[`Stdlib::HTTPUrl`]: https://github.com/puppetlabs/puppetlabs-stdlib/blob/0f032a9bc557949169f565bf41e5aa1f35b17346/REFERENCE.md#stdlibhttpurl

### Bug fixes

* Updated minimum Puppet version to match puppet/archive. [Archive version
  4.0.0][archive4] requires Puppet 5.5.8 or higher, so this module must as well.

[archive4]: https://forge.puppet.com/modules/puppet/archive/4.0.0

### Deprecations

* The [`$version`][$golang::version] parameter on `golang` is now deprecated.
  Pass the version to [`$ensure`][$golang::ensure] instead.
* The [`$source`][$golang::source] parameter on `golang` is now deprecated.
  Use [`golang::from_tarball`][] instead.

[`golang::installation`]: REFERENCE.md#golang--installation
[`golang::from_tarball`]: REFERENCE.md#golang--from_tarball
[`golang::linked_binaries`]: REFERENCE.md#golang--linked_binaries
[$golang::version]: REFERENCE.md#-golang--version
[$golang::ensure]: REFERENCE.md#-golang--ensure
[$golang::source]: REFERENCE.md#-golang--source

## Release 1.1.0

### Features

* Added `ensure` parameter to allow uninstalling Go.

### Bug fixes

* Used pre-release version of Puppet Strings to (mostly) fix parameter default
  values in [REFERENCE.md][].

[REFERENCE.md]: REFERENCE.md

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
