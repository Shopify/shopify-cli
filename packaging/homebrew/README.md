# Building a Homebrew package of the CLI

The Homebrew package of the CLI works as a proxy for the actual gem, by downloading it and installing the source code 
inside under brew.

Unlike Debian and RPM packages, this is not a metapackage, so the user will not be able to go between the brew and gem
versions of the package, unless they reinstall it from scratch.

To create new Homebrew builds, it is easier to run `rake package:homebrew` rather than to run the build by hand, but if 
you want to do that, follow the instructions below. These instructions are kept mostly for future reference.

## Requirements

Homebrew packages are slightly different from others in that they cannot be served as downloadable files. Therefore, 
the process for creating new versions is simply to create the new formula file from the template and upload it to the
tap.

The formula is built on top of the actual CLI gem, so the `package:gem` task needs to be run before the formula can be 
created. To do that manually, simply run `gem build <root>/shopify-cli.gemspec`.

## Formula creation

Before a package can be created, the metadata `.base.rb` file can be copied into a `.rb` file  which represents the
installable formula.

This file uses a few build-time variables that need to be replaced for manual builds:
* `SHOPIFY_CLI_VERSION`: The current CLI version
* `SHOPIFY_CLI_GEM_CHECKSUM`: The checksum of the gem
  * You can obtain this value by running `shasum -a 256 <path/to/gem> | awk '{ print $1 }'`

Once you create the `.rb` file, you can simply upload it to your tap repository. Users can then tap that repository and 
install the brew formula from it.

## Metadata updates

The CLI version number is obtained automatically by the Rake task (or manually set on manual builds), however if other
changes need to be made to the metadata, the `.base.rb` file can be updated accordingly to keep things consistent.
