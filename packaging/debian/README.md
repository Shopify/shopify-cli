# Building a .deb package of the CLI

The Debian package of the CLI is an empty metapackage that installs the CLI gem directly through Ruby. Therefore, the
package itself only serves to facilitate the installation and inclusion of non-ruby dependencies.

To create new Debian builds, it is easier to run `rake package:debian` rather than to run the build by hand, but if you
want to do that, follow the instructions below. These instructions are kept mostly for future reference.

## Requirements

The `dpkg-deb` program is required to build the actual package. It should be installed by default on Debian-based
systems, and it can be installed for Mac OS X via `brew`:

```
brew install dpkg
```

## Package creation

Before a package can be created, a few metadata files need to be put in the right place for the `dpkg` tool. Those files
all have `.base` versions for reference. They should be placed in `packaging/debian/shopify-cli/DEBIAN`:

* `control`
* `preinst` 
* `prerm`

All of those files reference the current CLI version as `SHOPIFY_CLI_VERSION`. This is filled automatically in the Rake
task, but it needs to be set manually for manual builds.

Once the changes above are made, run:

```
dpkg-deb -b shopify-cli
```

The final package will be written to `shopify-cli.deb`.

## Metadata updates

The CLI version number is obtained automatically by the Rake task (or manually set on manual builds), however if other
changes need to be made to the metadata, the `.base` files can be updated accordingly to keep things consistent.
