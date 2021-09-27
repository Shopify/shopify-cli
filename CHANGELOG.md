Unreleased
------
* [#1566](https://github.com/Shopify/shopify-cli/pull/1566): Fix bug when running `npm | yarn list` for extension package resolution
* [#1557](https://github.com/Shopify/shopify-cli/pull/1557): **Breaking** Move app commands under `shopify app`.
  
Version 2.5.0
------

* [#1553](https://github.com/Shopify/shopify-cli/pull/1553): Add support for PHP app projects

Version 2.4.0
------

* [#1488](https://github.com/Shopify/shopify-cli/pull/1488): Update Theme-Check to 1.4
* [#1507](https://github.com/Shopify/shopify-cli/pull/1507): Limit the generated name for themes to 50 characters
* [#1531](https://github.com/Shopify/shopify-cli/pull/1531): Migrate the analytics configuration to the global store.

Version 2.3.0
------

* [#1386](https://github.com/Shopify/shopify-cli/pull/1386): Update Theme-Check to 1.2
* [#1457](https://github.com/Shopify/shopify-cli/pull/1457): Fix uploading of binary theme files under Windows
* [#1480](https://github.com/Shopify/shopify-cli/pull/1480): Fix customers pages not working with `theme serve`
* [#1479](https://github.com/Shopify/shopify-cli/pull/1479): Add theme push & pull option to ignore files per command

Version 2.2.2
------
* [1382](https://github.com/Shopify/shopify-cli/pull/1382): Client side module upload for Scripts

Version 2.2.1
------

* [1432](https://github.com/Shopify/shopify-cli/pull/1432) New method for determining renderer package name

Version 2.2.0
------
* [#1424](https://github.com/Shopify/shopify-cli/pull/1424/): Add `--resourceUrl` flag to extension serve command
* [#1419](https://github.com/Shopify/shopify-cli/pull/1419): Remove analytics prompt when used in CI
* [#1418](https://github.com/Shopify/shopify-cli/pull/1418): Auto configure resource URL for Checkout Extensions
* [#1399](https://github.com/Shopify/shopify-cli/pull/1399): Fix error when running `shopify extension serve` in a theme app extension project

Version 2.1.0
-------------
* [#1357](https://github.com/Shopify/shopify-cli/pull/1357): Update Theme-Check to 1.1
* [#1352](https://github.com/Shopify/shopify-cli/pull/1352): Add `shopify extension check` for checking theme app extensions
* [#1304](https://github.com/Shopify/shopify-cli/pull/1304): Prompt user to run `shopify extension connect` if .env file is missing

Version 2.0.2
-------------
* [#1305](https://github.com/Shopify/shopify-cli/pull/1305): Fix `Uninitialized constant Net::WriteTimeout` error
* [#1319](https://github.com/Shopify/shopify-cli/pull/1319): Fix `theme pull` not pulling some files
* [#1321](https://github.com/Shopify/shopify-cli/pull/1321): Fix error when pulling images with `theme pull`
* [#1322](https://github.com/Shopify/shopify-cli/pull/1322): Fix error when running `shopify theme language-server --help`
* [#1324](https://github.com/Shopify/shopify-cli/pull/1324): Fix issue [#1308](https://github.com/Shopify/shopify-cli/issues/1308) where a non-English language on Partner Account breaks how CLI determines latest API version.
* [#1343](https://github.com/Shopify/shopify-cli/pull/1343): Fix inconsistent use of periods vs ellipsis in messages. This replaces periods with ellipsis.

Version 2.0.1
-------------
* [#1295](https://github.com/Shopify/shopify-cli/pull/1295): Ignore files at the root of a theme app extension project
* [#1296](https://github.com/Shopify/shopify-cli/pull/1296): Fix issue [#1294](https://github.com/Shopify/shopify-cli/issues/1294) regarding call to Windows `start` command with URL.
* [#1298](https://github.com/Shopify/shopify-cli/pull/1298): Fix error in `theme serve` command
* [#1301](https://github.com/Shopify/shopify-cli/pull/1301): Add `theme init` command

Version 2.0.0
-------------
* Adds support for theme development
* Changes to command structure (note that these are breaking changes, see [README](README.md))
* Checkout the [apps](https://shopify.dev/apps/tools/cli) and [themes](https://shopify.dev/themes/tools/cli) sections of the new [shopify.dev](https://shopify.dev) after Unite 2021 (June 29).

Version 1.14.0
--------------
* [#1275](https://github.com/Shopify/shopify-cli/pull/1275): Use script.json to specify script metadata
* [#1279](https://github.com/Shopify/shopify-cli/pull/1279): Fix bug where a script push still fails after the user answers the force push prompt
* [#1288](https://github.com/Shopify/shopify-cli/pull/1288): Fix bug where Scripts SDK was included for projects that don't require it

Version 1.13.1
--------------
* [#1274](https://github.com/Shopify/shopify-cli/pull/1274): Only print api_key during error if it exists
* [#1272](https://github.com/Shopify/shopify-cli/pull/1272): Fix minor bug with extension serve for UI extensions

Version 1.13.0
--------------

* [#1266](https://github.com/Shopify/shopify-cli/pull/1266): Developer Console release
* [#1265](https://github.com/Shopify/shopify-cli/pull/1265): Fix bug where commands hang after an unsuccessful authentication

Version 1.12.0
--------------
* [#1255](https://github.com/Shopify/shopify-cli/pull/1255): Fix beta flag checks when running `shopify serve`

Version 1.11.0
--------------
* [#1221](https://github.com/Shopify/shopify-cli/pull/1221): Prioritizes returning an HTTPS URL over HTTP from `shopify tunnel status`.
* [#1223](https://github.com/Shopify/shopify-cli/pull/1233): Running `shopify serve` in an extension project now automatically runs `shopify tunnel`.
* [#1225](https://github.com/Shopify/shopify-cli/pull/1225): Improved handling of "account not found" scenario, plus improvements to related tests and UX messaging
* [#1229](https://github.com/Shopify/shopify-cli/pull/1229): Allows Checkout Extensions to specify configuration attributes in their extension.config.yml file.
* [#1238](https://github.com/Shopify/shopify-cli/pull/1238): Auto Tunnel Support for Checkout Extension
* [#1256](https://github.com/Shopify/shopify-cli/pull/1256): Allow using spaces around the equal sign on .env file.

Version 1.10.0
--------------
* Updating internal features in development

Version 1.9.1
-------------
* [#1201](https://github.com/Shopify/shopify-cli/pull/1201) Determine Argo Renderer Dynamically. This fixes `shopify serve` and `shopify push` for extensions.

Version 1.9.0
-------------
* [#1181](https://github.com/Shopify/shopify-cli/pull/1181): Remove the subcommand references of the `generate` command for node apps (fixes [1176](https://github.com/Shopify/shopify-cli/issues/1176))

Version 1.8.0
-------------
* [#1119](https://github.com/Shopify/shopify-cli/pull/1119): Enable guest serialization for scripts

Version 1.7.1
------
* Updating internal features in development

Version 1.7.0
-----
* [#1109](https://github.com/Shopify/shopify-cli/pull/1109): Abort app generation if name contains disallowed text.
* [#1075](https://github.com/Shopify/shopify-cli/pull/1075): Add support for kebab-case flags

Version 1.6.0
-----
* [#1049](https://github.com/Shopify/shopify-cli/pull/1049): Add schema versioning support to the script project type
* [#1059](https://github.com/Shopify/shopify-cli/pull/1059): Remove the functionality of the `generate` command for node apps, since it will no longer be feasible with the new node library
* [#1046](https://github.com/Shopify/shopify-cli/pull/1046): Include a vendored copy of Webrick, as it's no longer included in Ruby 3.
* [#1041](https://github.com/Shopify/shopify-cli/pull/1041): Remove unnecessary shell call to `spring stop`. We already pass `--skip-spring` when creating the app so running `spring stop` would have no effect.
* [#1034](https://github.com/Shopify/shopify-cli/pull/1034): Abort if a system call fails.

Version 1.5.0
-----
* [#965](https://github.com/Shopify/shopify-cli/pull/965): Remove --no-optional when using npm to create new project
* [#958](https://github.com/Shopify/shopify-cli/pull/958): Split `connect` command into project-specific functionality
* [#992](https://github.com/Shopify/shopify-cli/pull/992): Add Theme Kit functionality to CLI

Version 1.4.1
------
* [#917](https://github.com/Shopify/shopify-cli/pull/917): Ensure analytics for create action includes the same fields as other commands

Version 1.4.0
------
* Updates to tests, dependencies and internal tooling
* [#924](https://github.com/Shopify/shopify-cli/pull/924): Improve debugging messages on Partner API errors

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
