Unreleased
------
* [1197](https://github.com/Shopify/shopify-app-cli/pull/1197): Add `create` command for PHP app projects.
* [1241](https://github.com/Shopify/shopify-app-cli/pull/1241): Add `serve` command for PHP app projects.
* [1243](https://github.com/Shopify/shopify-app-cli/pull/1243): Add `tunnel` command for PHP app projects.
* [1245](https://github.com/Shopify/shopify-app-cli/pull/1245): Add `connect` command for PHP app projects.
* [1247](https://github.com/Shopify/shopify-app-cli/pull/1247): Add `open` command for PHP app projects.
* [1252](https://github.com/Shopify/shopify-app-cli/pull/1252): Add `populate` command for PHP app projects.

Version 1.9.0
-------------
* [1181](https://github.com/Shopify/shopify-app-cli/pull/1181): Remove the subcommand references of the `generate` command for node apps (fixes [1176](https://github.com/Shopify/shopify-app-cli/issues/1176))

Version 1.8.0
-------------
* [1119](https://github.com/Shopify/shopify-app-cli/pull/1119): Enable guest serialization for scripts

Version 1.7.1
------
* Updating internal features in development

Version 1.7.0
-----
* [#1109](https://github.com/Shopify/shopify-app-cli/pull/1109): Abort app generation if name contains disallowed text.
* [#1075](https://github.com/Shopify/shopify-app-cli/pull/1075): Add support for kebab-case flags

Version 1.6.0
-----
* [#1049](https://github.com/Shopify/shopify-app-cli/pull/1049): Add schema versioning support to the script project type
* [#1059](https://github.com/Shopify/shopify-app-cli/pull/1059): Remove the functionality of the `generate` command for node apps, since it will no longer be feasible with the new node library
* [#1046](https://github.com/Shopify/shopify-app-cli/pull/1046): Include a vendored copy of Webrick, as it's no longer included in Ruby 3.
* [#1041](https://github.com/Shopify/shopify-app-cli/pull/1041): Remove unnecessary shell call to `spring stop`. We already pass `--skip-spring` when creating the app so running `spring stop` would have no effect.
* [#1034](https://github.com/Shopify/shopify-app-cli/pull/1034): Abort if a system call fails.

Version 1.5.0
-----
* [#965](https://github.com/Shopify/shopify-app-cli/pull/965): Remove --no-optional when using npm to create new project
* [#958](https://github.com/Shopify/shopify-app-cli/pull/958): Split `connect` command into project-specific functionality
* [#992](https://github.com/Shopify/shopify-app-cli/pull/992): Add Theme Kit functionality to CLI

Version 1.4.1
------
* [#917](https://github.com/Shopify/shopify-app-cli/pull/917): Ensure analytics for create action includes the same fields as other commands

Version 1.4.0
------
* Updates to tests, dependencies and internal tooling
* [#924](https://github.com/Shopify/shopify-app-cli/pull/924): Improve debugging messages on Partner API errors

Version 1.3.1
------
* Allow any characters in ngrok account names

Version 1.3.0
------
* Support for new `shopify config analytics` command to enable/disable anonymous usage reporting

Version 1.2.0
------
* Improvements and new functionality to various internal components

Version 1.1.2
------
* Fix various minor bugs (check dir before creating Rails project, catch stderr from failed git command)

Version 1.1.1
------
* Fix a bug where usernames with spaces caused issues on Windows

Version 1.1.0
------
* Add native Windows 10 support, including variety of stability fixes.

Version 1.0.5
------
* Fix a bug in out opt-in metrics

Version 1.0.4
------
* Fix a bug when running the `connect` command with an account with multiple organizations

Version 1.0.3
------
* Fix a bug which causes an error in the `populate` and `generate` commands when prompting for the shop name

Version 1.0.2
------
* Fix missing shop parameter to AdminAPI.query() call (impacting populate and generate commands)

Version 1.0.1
------
* Fixed an issue with RVM taking over the shell shim fd when it was not in use

Version 1.0.0
------
* Release the installer-based version of the CLI

Version 0.9.3 - Internal Test Version
------
* Rebased to master
* Removed auto-generated files from builds directory

Version 0.9.2 - Internal Test Version
------
* Rebased to master, to pull in 7+ Pull Requests
* Updates to dependencies to package files (updated Ruby version)

Version 0.9.1 - Internal Test Version
------
* Updated required Ruby version for the CLI
* Minor fixes for the build / release process

Version 0.9.0 - Internal Test Version
------
* Initial test release of gem-based CLI
