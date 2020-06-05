# Building a .rpm package of the CLI

The RPM package of the CLI is simply a metapackage that installs the CLI gem directly through Ruby. Therefore, 
the package itself only serves to facilitate the installation and inclusion of non-ruby dependencies.

## Requirements

The `gem2rpm` gem can be used to manage the package templates, even though it's not necessarily used to build the 
package itself. To install it, simply run:

```
gem install gem2rpm 
```

To build the actual packages, you'll also need the `rpm` package from brew:

```
brew install rpm
```

## Package creation

If there is a need to bump the version of the metapackage, one needs to re-generate the RPM spec file based on the 
template. This can be done automatically by `gem2rpm`, by running:

```
gem2rpm -t rubygem-shopify.spec.template <path>/shopify-X.Y.Z.gem > rubygem-shopify.spec
```

Then, build the RPM package itself based on the spec:

```
cd packaging/rpm
rpmbuild -bb rubygem-shopify.spec
```

## Version changes

If the required Ruby version changes, make sure to update the `.spec.template` file to reflect that. There seems to be a
bug in `gem2rpm` that causes the ruby version from the gemspec to be placed inside `[]`, which fails the build.
