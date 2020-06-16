# Building a .rpm package of the CLI

The RPM package of the CLI is simply a metapackage that installs the CLI gem directly through Ruby. Therefore, 
the package itself only serves to facilitate the installation and inclusion of non-ruby dependencies.

To create new RPM builds, it is easier to run `rake package:rpm` rather than to run the build by hand, but if you
want to do that, follow the instructions below. These instructions are kept mostly for future reference.

## Requirements

To build RPM packages, you'll need the `rpmbuild` program. It can be installed on Mac OS via `brew`:

```
brew install rpm
```

Or via `yum` on Linux:

```
yum install rpm-build
```

## Package creation

Before a package can be created, the metadata `.spec.base` file can be copied into the `.spec` file to be used for the
build. This file references the current CLI version as `SHOPIFY_CLI_VERSION`. This is filled automatically in the Rake
task, but it needs to be set manually for manual builds.

Once you have a working spec, build the RPM package itself by running:

```
cd packaging/rpm
rpmbuild -bb rubygem-shopify.spec
```

The package file will be saved in `build/noarch`.

## Metadata updates

The CLI version number is obtained automatically by the Rake task (or manually set on manual builds), however if other
changes need to be made to the metadata, the `.spec.base` file can be updated accordingly to keep things consistent.
