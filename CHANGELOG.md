# Changelog

All notable changes to this project will be documented in this file.

## Release 1.0.4

**Features**

* Latest Go version (1.16.7) installed by default.

**Bugfixes**

* The `godoc` binary no longer ships in the Go package, so this no longer links
  it into `/usr/local/bin` by default. **Note:** this does not remove the link
  if it already exists.
* Metadata updated to support the most recent version of
  [puppet/archive](https://forge.puppet.com/modules/puppet/archive).

## Release 1.0.3

**Features**

* [#2](https://github.com/danielparks/puppet-golang/issues/2): support
  convenient installation on Raspberry Pi 2B and 3B.

**Bugfixes**

* [#2](https://github.com/danielparks/puppet-golang/issues/2): default to the
  correct 64-bit ARM binary on 64 bit ARM, e.g. on the Raspberry Pi 4.

## Release 1.0.2

**Features**

* Latest Go version (1.13.6) installed by default.
* [#2](https://github.com/danielparks/puppet-golang/issues/2): support
  convenient installation on Raspberry Pi 4.
