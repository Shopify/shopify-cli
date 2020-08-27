# Building a .nupkg package of the CLI

The Chocolatey package of the CLI is an empty metapackage that installs the CLI gem directly through Ruby. Therefore,
the package itself only serves to facilitate the installation and inclusion of non-ruby dependencies.

To create new Chocolatey builds, it is easier to run `rake package:choco` rather than to run the build by hand, but if 
you want to do that, follow the instructions below. These instructions are kept mostly for future reference.

## Requirements

To build the package, you'll need the `mono` runtime and the built `choco` tool. To install mono you can run:

```
brew install mono
```

## Building the choco tool (optional)

This repository includes a static build of the `choco` tool, which was built with `mono`.

If you wish to update the static build, here are the steps to build the `choco` tool so packages can be created.

```
NOTE: This MUST be done on Linux as Mac is not properly supported yet
```

* Download and unpack the latest `choco` code:
  * `wget https://github.com/chocolatey/choco/archive/stable.zip`
  * `unzip stable.zip`
  * `rm stable.zip`
* Build the tool:
  * `cd choco-stable`
  * `chmod +x build.sh zip.sh`
  * `./build.sh`
  
For more information on this process, visit the [Choco GitHub page](https://github.com/chocolatey/choco#compiling--building-source).
  
The contents of `build_output/chocolatey` are what we need to build the actual packages. You can run

```
mono /path/to/build/choco.exe
```

## Package creation

Before a package can be created, the `.nuspec` metadata file needs to be put in the right place for the `choco` tool.
There is a `shopify-cli.base.nuspec` template file for reference. You can create a version of the file for your build 
and `cd` into the dir where it will be output.

That file references the current CLI version as `SHOPIFY_CLI_VERSION`. This is filled automatically in the Rake task,
but it needs to be set manually for manual builds.

Once the changes above are made, run:

```
mono /path/to/build/choco.exe shopify-cli.nuspec
```

The final package will be written to `shopify-cli.X.Y.Z.nupkg`.

## Metadata updates

The CLI version number is obtained automatically by the Rake task (or manually set on manual builds), however if other
changes need to be made to the metadata, the `.base` file can be updated accordingly to keep things consistent.
