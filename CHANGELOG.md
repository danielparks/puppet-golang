# Change log

All notable changes to this project will be documented in this file.

## main branch

* Synced with [PDK][].

[PDK]: https://www.puppet.com/docs/pdk/latest/pdk.html

## Release 1.2.8

## Release 1.2.7

### Security fix

Certain Go tarballs (see below) had files owned by non-root users:

    ❯ curl -SsL https://go.dev/dl/go1.20.14.darwin-amd64.tar.gz | tar -tzvf - | head -3
    drwxr-xr-x  0 0      0           0 Feb  2 10:19 go/
    -rw-r--r--  0 gopher wheel    1339 Feb  2 10:09 go/CONTRIBUTING.md
    -rw-r--r--  0 gopher wheel    1479 Feb  2 10:09 go/LICENSE

In this case, the non-root user in question mapped to the first user created on
the macOS system (UID 501).

When running as root, previous versions of dp-golang would preserve file
ownership when extracting the tarball, even if `owner` was set to something
else. **This meant that files, such as the `go` binary, ended up being writable
by a non-root user.**

This version of dp-golang enables [`tar`]’s `--no-same-owner` and
`--no-same-permissions` flags, which cause files to be extracted as the user
running Puppet, or as the user/group specified in the Puppet code.

GitHub security advisory: [GHSA-8h8m-h98f-vv84]

#### Affected Go tarballs

  * Go for macOS version 1.4.3 through 1.21rc3, inclusive.
  * go1.4-bootstrap-20170518.tar.gz
  * go1.4-bootstrap-20170531.tar.gz

[`tar`]: https://www.man7.org/linux/man-pages/man1/tar.1.html
[GHSA-8h8m-h98f-vv84]: https://github.com/danielparks/puppet-golang/security/advisories/GHSA-8h8m-h98f-vv84

### Changes

As part of the security fix mentioned above, it became necessary to be more
agressive about ensuring that the owner and group of files in the installation
are correct. dp-golang now deletes and recreates any Go installation it finds
that has a file or directory with the wrong owner or group.

## Release 1.2.6

* Synced with [PDK][].

[PDK]: https://www.puppet.com/docs/pdk/latest/pdk.html

## Release 1.2.5

* Updated automatic PR checks to run acceptance tests with both Puppet 7 and
  Puppet 8 (Puppet 6 is still supported by this module, but unfortunately the
  [acceptance test framework][litmus] does not support it).
* Updated metadata to support [puppet/archive 7.0.0][archive7].
* Synced with [PDK][].

[litmus]: https://puppetlabs.github.io/litmus/
[archive7]: https://forge.puppet.com/modules/puppet/archive/7.0.0/changelog#v700-2023-06-04
[PDK]: https://www.puppet.com/docs/pdk/latest/pdk.html

## Release 1.2.4

* Added a section about development status (stable; no features planned) to
  [README.md][].
* Synced with [PDK][].

[README.md]: README.md
[PDK]: https://www.puppet.com/docs/pdk/2.x/pdk.html

## Release 1.2.3

No functional changes. This release is solely to keep the released module from
getting too far out of sync with git after multiple `pdk update`s.

## Release 1.2.2

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
