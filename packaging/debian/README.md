# Building a .deb package of the CLI

The Debian package of the CLI is simply a metapackage that installs the CLI gem directly through Ruby. Therefore, 
the package itself only serves to facilitate the installation and inclusion of non-ruby dependencies.

## Requirements

The `dpkg-deb` program is required to build the actual package. It can be installed for Mac OS X via `brew`:

```
brew install dpkg
```

## Package creation

If there is a need to bump the version of the metapackage, one needs to:

* Update the `DEBIAN/control` file accordingly
* Change the gem installation command if needed in `DEBIAN/postinst`

Once the changes above are made, run:

```
dpkg-deb -b shopify-cli
```