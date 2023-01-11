From version 2.6.0, the sections in this file adhere to the [keep a changelog](https://keepachangelog.com/en/1.0.0/) specification.

## [Unreleased]

## Version 2.34.0 - 2023-01-11

### Added
* [#2715](https://github.com/Shopify/shopify-cli/pull/2715): Update theme-check to 1.14.0 (introduce section groups support)
* [#2714](https://github.com/Shopify/shopify-cli/pull/2714): Update theme-check to 1.13.0 (introduce section groups support)

## Version 2.33.1 - 2023-01-09

### Fixed
* [#2706](https://github.com/Shopify/shopify-cli/pull/2706): Delete checksum after file deletion

## Version 2.33.0 - 2022-12-19

### Added
* [#2681](https://github.com/Shopify/shopify-cli/pull/2681): Enable Theme Access passwords for theme serve
* [#2701](https://github.com/Shopify/shopify-cli/pull/2701): Update theme-check to 1.12.1 (introduce intelligent code completion)

## Version 2.32.1 - 2022-12-05

### Fixed
* [#2694](https://github.com/Shopify/shopify-cli/pull/2694): Add sunset warnings

## Version 2.32.0 - 2022-11-14

### Added
* [#2680](https://github.com/Shopify/shopify-cli/pull/2680): Validate on `shopify theme share/pull/push/serve` if users are running the command in a theme/empty directory

### Fixed
* [#2683](https://github.com/Shopify/shopify-cli/pull/2683): Fix timeout issue with the `shopify theme push` command and the `--json` flag
* [#2688](https://github.com/Shopify/shopify-cli/pull/2688): Fix `shopify theme push` to report pushes with errors

## Version 2.31.0 - 2022-11-07

### Added
* [#2676](https://github.com/Shopify/shopify-cli/pull/2676): Introduce shorthand `-e` for `--theme-editor-sync` in `shopify theme serve`

## Version 2.30.0 - 2022-11-01

### Fixed
* [#2668](https://github.com/Shopify/shopify-cli/pull/2668): Introduce `--only/--ignore` in the `shopify theme serve` help message
* [#2667](https://github.com/Shopify/shopify-cli/pull/2667): Fix for "X zip is required for packaging a theme" on Windows

## Version 2.29.0 - 2022-10-19

### Added
* [#2664](https://github.com/Shopify/shopify-cli/pull/2664): Enable Theme Kit Access passwords

## Version 2.28.0 - 2022-10-17

### Fixed
* [#2646](https://github.com/Shopify/shopify-cli/pull/2646): Demo themes shouldn't appear in the `shopify theme pull/push/list/open` commands
* [#2650](https://github.com/Shopify/shopify-cli/pull/2650): The `shopify theme push`/`shopify theme serve` commands no longer freeze in some scenarios

### Changed
* [#2648](https://github.com/Shopify/shopify-cli/pull/2648): Do not warn users when the CLI 2.x is running as a subprocess

## Version 2.27.0 - 2022-10-10

### Fixed
* [#2645](https://github.com/Shopify/shopify-cli/pull/2645): Fix issue that prevents the execution of `shopify extension serve` in some scenarios

## Version 2.26.0 - 2022-10-03

### Added
* [#2636](https://github.com/Shopify/shopify-cli/pull/2636): Show store when the CLI prompts users to select a theme

## Version 2.25.0 - 2022-09-14

### Added
* [#2600](https://github.com/Shopify/shopify-cli/pull/2600): Add support to the `SIGTERM` signal
* [#2602](https://github.com/Shopify/shopify-cli/pull/2602): Add `--only/--ignore` support to the `theme serve` command

### Fixed
* [#2607](https://github.com/Shopify/shopify-cli/pull/2607): Fix proxy to redirect to host and port set by cli

## Version 2.24.0 - 2022-08-29

### Fixed
* [#2572](https://github.com/Shopify/shopify-cli/pull/2572): **Breaking** Update theme-check to 1.11.0 (dropped support for ruby 2.6)

## Version 2.23.0 - 2022-08-22

### Fixed
* [#2528](https://github.com/Shopify/shopify-cli/pull/2528): Switch from using absolute file paths to relative paths for ignore filter

### Added
* [#2520](https://github.com/Shopify/shopify-cli/pull/2520): Add the option to ignore new version warnings by passing the `SHOPIFY_CLI_RUN_AS_SUBPROCESS` environment variable
* [#2440](https://github.com/Shopify/shopify-cli/pull/2440): Warn when using CLI 2.0 in a CLI 3.0 project

## Version 2.22.0 - 2022-08-08

### Fixed
* [#2512](https://github.com/Shopify/shopify-cli/pull/2512): Add the `-t/--theme` parameter to the `shopify theme serve -h` message
* [#2505](https://github.com/Shopify/shopify-cli/pull/2505): Show warning messages when `shopify theme push/pull` has errors

## Version 2.21.0 - 2022-08-03

### Fixed
* [#2453](https://github.com/Shopify/shopify-cli/pull/2453): Fix [#2382](https://github.com/Shopify/shopify-cli/issues/2382): Ensure we wait 24 hours to show update message again
* [#2463](https://github.com/Shopify/shopify-cli/pull/2463): Fix for "Keep the remote version" deletes files on new development theme
* [#2405](https://github.com/Shopify/shopify-cli/pull/2405): Fix `theme serve` to trigger page refresh when a file is deleted
* [#2489](https://github.com/Shopify/shopify-cli/pull/2489): Fix `theme serve` to hot reload many occurrences of a stylesheet

### Added
* [#2496](https://github.com/Shopify/shopify-cli/pull/2496): Accept storefront renderer token from ENV variable

## Version 2.20.1 - 2022-07-18

### Fixed
* [#2458](https://github.com/Shopify/shopify-cli/pull/2458): Fix shop URL in unauthorized error message
* [#2459](https://github.com/Shopify/shopify-cli/pull/2459): Fix `.json` file ignore issues with `shopify theme push`
* [#2460](https://github.com/Shopify/shopify-cli/pull/2460): Fix job retries for .json theme file dependencies and support wider range of asset API errors

## Version 2.20.0 - 2022-07-11

### Added
* [#2368](https://github.com/Shopify/shopify-cli/pull/2368): Add performance enhancements to the `theme serve` and `theme push` commands
* [#2437](https://github.com/Shopify/shopify-cli/pull/2437): Add support to the `warnings` field in the assets API
* [#2446](https://github.com/Shopify/shopify-cli/pull/2446): Show a friendly message when developers use a browser without SSE support

### Fixed
* [#2418](https://github.com/Shopify/shopify-cli/pull/2418): Improve the help message of the `theme open -e/--editor` flag

### Changed
* [#2444](https://github.com/Shopify/shopify-cli/pull/2444): Expose the `-s` option in the help text of `login`, `switch` etc.

## Version 2.18.0 - 2022-05-30

### Added
* [#2336](https://github.com/Shopify/shopify-cli/pull/2336): Add `--theme/-t` flag support to the `theme serve` command
* [#2325](https://github.com/Shopify/shopify-cli/pull/2325): Add `-e/--editor` flag to open theme editor in the `theme open` command
* [#2330](https://github.com/Shopify/shopify-cli/pull/2330): Add remote file deleted warning flow to `theme serve --theme-editor-sync`

### Fixed
* [#2352](https://github.com/Shopify/shopify-cli/pull/2352): Provide better DX when dealing with empty theme selection
* [#2347](https://github.com/Shopify/shopify-cli/pull/2347): Fix #2346 Heroku CLI installation for Apple silicon
* [#2422](https://github.com/Shopify/shopify-cli/pull/2422): Add Shopify branding and styling to post-authentication browser page

## Version 2.17.0 - 2022-05-12

### Added
* [#2262](https://github.com/Shopify/shopify-cli/pull/2262): Add `capabilities` permissions to checkout extensions config
* [#2292](https://github.com/Shopify/shopify-cli/pull/2292): Add support for App Bridge create/details URLs for scripts

### Fixed
* [#2287](https://github.com/Shopify/shopify-cli/pull/2287): Fix `Encoding::UndefinedConversionError` on `theme serve` and `theme pull`
* [#2310](https://github.com/Shopify/shopify-cli/pull/2310): Fix live-reload to be resilient and no longer raise an error when a locale file is invalid
* [#2297](https://github.com/Shopify/shopify-cli/pull/2297): Only show update message when the new version is higher
* [#2270](https://github.com/Shopify/shopify-cli/pull/2270): Use ignore filter regex in watcher class

### Changed
* [#2299](https://github.com/Shopify/shopify-cli/pull/2299): Improve the unauthorized API errors when doing theme development

## Version 2.16.1 - 2022-04-26

### Fixed
* [#2279](https://github.com/Shopify/shopify-cli/pull/2279): Fix logout when there are theme permission issues
* [#2285](https://github.com/Shopify/shopify-cli/pull/2285): Fix extension loading for extension connect
* [#2284](https://github.com/Shopify/shopify-cli/pull/2284): Fix version check for Windows

## Version 2.16.0 - 2022-04-25

### Fixed
* [#2274](https://github.com/Shopify/shopify-cli/pull/2274): Fix broken `shopify extension register` and `shopify extension push`

### Added
* [#2189](https://github.com/Shopify/shopify-cli/pull/2189): Retrieve latest CLI version in the background
* [#2263](https://github.com/Shopify/shopify-cli/pull/2263): Add `POS UI Extension` to support third party developers to extend POS smart grid functionality using native retail components.

### Changed
* [#2272](https://github.com/Shopify/shopify-cli/pull/2272): Changed interactive apps list scope for extension create|register|connect commands

## Version 2.15.6 - 2022-04-12

### Fixed
* [#2246](https://github.com/Shopify/shopify-cli/pull/2246): Fix callback urls for app serve

## Version 2.15.5 - 2022-04-08

### Fixed
* [#2237](https://github.com/Shopify/shopify-cli/pull/2237): Fix Homebrew Wrapper

## Version 2.15.4 - 2022-04-08

### Fixed
* [#2230](https://github.com/Shopify/shopify-cli/pull/2230): Show an error without ngrok account
* [#2235](https://github.com/Shopify/shopify-cli/pull/2235): Update shopify-extensions to v0.3.0 and fix issues with template choosing and missing dependencies
* [#2226](https://github.com/Shopify/shopify-cli/pull/2226): Fix liquid file size validation to disclude locales directory

## Version 2.15.3 - 2022-04-07

### Changed
* [#2188](https://github.com/Shopify/shopify-cli/pull/2188): Update URLs by default on serve and add --no-update flag to skip it
* [#2203](https://github.com/Shopify/shopify-cli/pull/2203): Use javy version 0.3.0

### Fixed
* [#2162](https://github.com/Shopify/shopify-cli/pull/2162): Improve encoding error handling for Checkout Extension localization
* [#2187](https://github.com/Shopify/shopify-cli/pull/2187): Fix app serve after rails update
* [#2191](https://github.com/Shopify/shopify-cli/pull/2191): Directories with the `.json` extension should not be handled as JSON files
* [#2018](https://github.com/Shopify/shopify-cli/pull/2018): Run theme-check as a code dependency, not a pseudo-CLI invocation
* [#2211](https://github.com/Shopify/shopify-cli/pull/2211): Fix the `theme open` command to open the theme in the browser
* [#2183](https://github.com/Shopify/shopify-cli/pull/2183): Improve error message when suspended users run `theme serve`
* [#2219](https://github.com/Shopify/shopify-cli/pull/2219): Fix issues when creating Rails apps after the release of `shopify_app` v19

### Added
* [#2190](https://github.com/Shopify/shopify-cli/pull/2190): Better login experience with spinner
* [#2200](https://github.com/Shopify/shopify-cli/pull/2200): Add `theme share` command

## Version 2.15.2 - 2022-03-28

### Fixed
* [#2121](https://github.com/Shopify/shopify-cli/pull/2121): Fix the hot-reload to work when the section name is not equal to the type

### Added
* [#2174](https://github.com/Shopify/shopify-cli/pull/2174): Add optional 2-way sync between the CLI (`theme serve`) and the Theme Editor

## Version 2.15.1 - 2022-03-24

### Added
* [#1934](https://github.com/Shopify/shopify-cli/pull/1934): Block directories in theme assets
* [#1880](https://github.com/Shopify/shopify-cli/pull/1880): Recognize attempts to pass a store name and suggest correction

### Fixed
* [#1874](https://github.com/Shopify/shopify-cli/pull/1874): Make ngrok errors more robust and helpful
* [#2172](https://github.com/Shopify/shopify-cli/pull/2172): Fix Ruby check for Rails app creation

## Version 2.15.0 - 2022-03-21

### Fixed
* [#2086](https://github.com/Shopify/shopify-cli/pull/2086): Improve check of dependency versions
* [#2149](https://github.com/Shopify/shopify-cli/pull/2149): Fix `ThemeAdminAPI` not to handle asset errors
* [#2122](https://github.com/Shopify/shopify-cli/pull/2122): Fix `--only`/`--ignore` flags parser to support multiple occurrences without quotes
* [#2146](https://github.com/Shopify/shopify-cli/pull/2146): Prevent duplicate locales for Checkout extension localization

## Version 2.14.0 - 2022-03-15

### Changed
* [#2126](https://github.com/Shopify/shopify-cli/pull/2126): Use javy version 0.2.1

### Added
* [#2103](https://github.com/Shopify/shopify-cli/pull/2103): Improve `shopify theme package` to include the `release-notes.md` file

### Fixed
* [#2112](https://github.com/Shopify/shopify-cli/pull/2112): Fix intermittent error ("can't add a new key into hash during iteration") in the `theme push` command
* [#2088](https://github.com/Shopify/shopify-cli/pull/2088): Update theme-check to 1.10.1
* [#2130](https://github.com/Shopify/shopify-cli/pull/2130): Fix Homebrew installation.
* [#2133](https://github.com/Shopify/shopify-cli/pull/2133): Fix ignore file handling in DevServer::Watcher.

## Version 2.13.0 - 2022-03-02

### Added
* [#2087](https://github.com/Shopify/shopify-cli/pull/2087): Add new Theme CLI commands: `theme list` and `theme open`
* [#2035](https://github.com/Shopify/shopify-cli/pull/2035): Support Ruby 3.1

### Fixed
* [#2092](https://github.com/Shopify/shopify-cli/pull/2092): Fix `RootHelper` parse logic to support options with an equal (e.g.: `option=value`)
* [#2089](https://github.com/Shopify/shopify-cli/pull/2089): Use javy version 0.2.0
* [#2114](https://github.com/Shopify/shopify-cli/pull/2114): Fix `theme` command error messaging with `ThemeAdminAPI` wrapper

### Removed
* [#2102](https://github.com/Shopify/shopify-cli/pull/2102): Remove AssemblyScript as a supported script language.

## Version 2.12.0 - 2022-02-23

### Added
* [#1866](https://github.com/Shopify/shopify-cli/pull/1866): Enforce git dependency
* [#2009](https://github.com/Shopify/shopify-cli/pull/2009): Add localization support for Checkout Extensions
* [#2060](https://github.com/Shopify/shopify-cli/pull/2060): Improve CLI error messages for token-based auth (scripts)
* [#2076](https://github.com/Shopify/shopify-cli/pull/2076): Release Wasm Script Projects
* [#2051](https://github.com/Shopify/shopify-cli/pull/2051): Update `theme serve` to accept `root` argument
* [#2025](https://github.com/Shopify/shopify-cli/pull/2025): Improve `theme pull`/`push` help messages to indicate multiple `--only`/`--ignore` flags are allowed.

### Fixed
* [#2030](https://github.com/Shopify/shopify-cli/pull/2030): Fix Theme::Syncer handling of file deletions in `download_file!`
* [#2071](https://github.com/Shopify/shopify-cli/pull/2071): Fix `theme pull` error message when dev theme doesn't exist
* [#2066](https://github.com/Shopify/shopify-cli/pull/2066): Improve `--only`/`--ignore` parameters on Theme `pull`/`push` commands to work without quotes
* [#2078](https://github.com/Shopify/shopify-cli/pull/2078): Fix errors on section rendering caused by CORS issues

## Version 2.11.2 - 2022-02-14

### Fixed
* [#2047](https://github.com/Shopify/shopify-cli/pull/2047): Fix the Homebrew installation
* [#2019](https://github.com/Shopify/shopify-cli/pull/2019): Provide helpful link when nokogiri fails to load
* [#2055](https://github.com/Shopify/shopify-cli/pull/2055): Remove unneeded Node requirements
* [#2020](https://github.com/Shopify/shopify-cli/pull/2020): Fix `theme pull` so that correct dev theme is used with `-d` option

## Version 2.11.1 - 2022-02-09

### Fixed
* [#1973](https://github.com/Shopify/shopify-cli/pull/1973): Fix `theme serve` to preview generated files (`*.css.liquid`)
* [#2034](https://github.com/Shopify/shopify-cli/pull/2034): Fix `theme serve` to accept parameters with multiple values
* [#2033](https://github.com/Shopify/shopify-cli/pull/2033): Pin Homebrew Ruby to 3.0
* [#2032](https://github.com/Shopify/shopify-cli/pull/2032): Runtime error checking the Node version if Node is not present in the environment.

## Version 2.11.0 - 2022-02-07

### Fixed
* [#2005](https://github.com/Shopify/shopify-cli/pull/2005): Fix PHP app serve on Windows environments

### Added
* [#1998](https://github.com/Shopify/shopify-cli/pull/1998): Add support for Rails 7
* [#1945](https://github.com/Shopify/shopify-cli/pull/1945): Check Node and Ruby versions and warn the user if their environment's version might be incompatible with the version the command expects.
* [#2011](https://github.com/Shopify/shopify-cli/pull/2011): Adds support for the Spin rewrite

### Changed
* [#2001](https://github.com/Shopify/shopify-cli/pull/2001): Improve Bug Issue Template. Includes autofill of CLI/Ruby/environment information.
* [#2004](https://github.com/Shopify/shopify-cli/pull/2004): Template improvements II. Includes autofill of Shell if $SHELL is set.
* [#2002](https://github.com/Shopify/shopify-cli/pull/2002): Update `-o`/`--only` parameter to allow multiple patterns on `theme push`/`theme pull` commands
* [#2022](https://github.com/Shopify/shopify-cli/pull/2022): Don't warn the user if the Ruby version is in the range 3.0.x.

## Version 2.10.2 - 2022-01-31

### Fixed
* [#1983](https://github.com/Shopify/shopify-cli/pull/1983): Improve Windows compatibility
* [#1928](https://github.com/Shopify/shopify-cli/pull/1928): Ensure script Wasm file sizes don't exceed the limit
* [#2006](https://github.com/Shopify/shopify-cli/pull/2006): Fix: More defensive URL generation

## Version 2.10.1 - 2022-01-28

### Fixed
* [#1985](https://github.com/Shopify/shopify-cli/pull/1985): Revert "Fix CORS (Cross-origin resource sharing) errors (#1952)"

## Version 2.10.0 - 2022-01-25

### Fixed
* [#1937](https://github.com/Shopify/shopify-cli/pull/1937): Fix `theme pull` to no longer add empty lines on Windows
* [#1952](https://github.com/Shopify/shopify-cli/pull/1952): Fix CORS (cross-origin resource sharing) errors
* [#1965](https://github.com/Shopify/shopify-cli/pull/1965): Revert: Fix partners ability to login to external shops. (#1873)

### Added
* [#1892](https://github.com/Shopify/shopify-cli/pull/1892): Add `-o`/`--only` parameter to filter files on `theme push`/`theme pull` commands

## Version 2.9.0 - 2022-01-17

### Fixed
* [#1922](https://github.com/Shopify/shopify-cli/pull/1922): Respect RUBY_BINDIR from Homebrew for installing gem
* [#1906](https://github.com/Shopify/shopify-cli/pull/1906): Fix Ngrok incompatibility with some Apple ARM environments
* [#1873](https://github.com/Shopify/shopify-cli/pull/1873): Fix partners ability to login to external shops.
* [#1909](https://github.com/Shopify/shopify-cli/pull/1909): Fix `theme serve` on Safari

### Added
* [#1900](https://github.com/Shopify/shopify-cli/pull/1900): Add `-d`/`--development` flag to Shopify theme pull command
* [#1891](https://github.com/Shopify/shopify-cli/pull/1891): Allow for additional arguments in `shopify push script` on CI.
* [#1877](https://github.com/Shopify/shopify-cli/pull/1877): Add theme (`-t`/`--theme=NAME_OR_ID`) parameter to `theme push`/`theme pull` commands
* [#1871](https://github.com/Shopify/shopify-cli/pull/1871): Add a new `--live-reload` parameter to the `theme serve` command

### Changed
* [#1929](https://github.com/Shopify/shopify-cli/pull/1929): Rename `--registration-id` to `--extension-id` in `shopify extension push`.

## Version 2.8.0 - 2022-01-06

### Fixed
* [#1879](https://github.com/Shopify/shopify-cli/pull/1879): Disambiguate -s as store option

## Version 2.7.4 - 2021-12-22

### Added
* [#1825](https://github.com/Shopify/shopify-cli/pull/1825): Support passing the connection information through arguments

### Fixed
* [#1852](https://github.com/Shopify/shopify-cli/pull/1852): Fix `shopify --help` to include `extension` commands
* [#1853](https://github.com/Shopify/shopify-cli/pull/1853): Fix javy installation failures from MacOS universal ruby installations
* [#1851](https://github.com/Shopify/shopify-cli/pull/1851): Improve `shopify theme push --live` confirmation message to show current live theme
* [#1850](https://github.com/Shopify/shopify-cli/pull/1850): Fix `shopify extension` commands timeout when organization has too many apps
* [#1860](https://github.com/Shopify/shopify-cli/pull/1860): Fix `theme serve` hot reload when there are many tabs active

## Version 2.7.3 - 2021-12-13

### Added
* [#1826](https://github.com/Shopify/shopify-cli/pull/1826): Support using `script.config.yml` file for script configuration
* [#1843](https://github.com/Shopify/shopify-cli/pull/1843): Support using javy on Apple ARM processors
* [#1847](https://github.com/Shopify/shopify-cli/pull/1847): `shopify script connect` command.

### Fixed
* [#1811](https://github.com/Shopify/shopify-cli/pull/1811): Update theme-check to 1.9.0
* [#1831](https://github.com/Shopify/shopify-cli/pull/1831): Ensure correct `ngrok` version is downloaded for Apple M1
* [#1823](https://github.com/Shopify/shopify-cli/pull/1823): Indicate git is unavailable; don't error out
* [#1807](https://github.com/Shopify/shopify-cli/pull/1807): Fix `--live` parameter, it should not imply `--allow-live` in the `theme push` command
* [#1812](https://github.com/Shopify/shopify-cli/pull/1812): App creation with Rails 7
* [#1821](https://github.com/Shopify/shopify-cli/pull/1821): Fix Shopify hosted fonts to load via the local preview URL
* [#1830](https://github.com/Shopify/shopify-cli/pull/1830): Fix hot reload when users update many files "simultaneously"
* [#1837](https://github.com/Shopify/shopify-cli/pull/1837): Fix `ShopifyCLI::Theme::DevServer::CdnFonts` class to support any font

## Version 2.7.2 - 2021-11-30

### Fixed
* [#1763](https://github.com/Shopify/shopify-cli/pull/1763): Fix: Tunnel --PORT parameter not working in Node.js app.
* [#1769](https://github.com/Shopify/shopify-cli/pull/1769): Fix `theme push --development --json` to output the proper exit code
* [#1766](https://github.com/Shopify/shopify-cli/pull/1766): Fix `theme serve` failing with the `--host` property
* [#1771](https://github.com/Shopify/shopify-cli/pull/1771): Fix `theme push --development --json` to output errors in the STDERR
* [#1778](https://github.com/Shopify/shopify-cli/pull/1778): Fix ngrok installation check on Windows
* [#1798](https://github.com/Shopify/shopify-cli/pull/1798): Add `--live` option to the `theme pull` and the `theme push` commands
* [#1788](https://github.com/Shopify/shopify-cli/pull/1788): Improve `theme serve` errors and add logs for successful operations
* [#1794](https://github.com/Shopify/shopify-cli/pull/1794): Fix bug where hidden subcommands appear in the help menu.

## Version 2.7.1 - 2021-11-17

### Fixed
* [#1722](https://github.com/Shopify/shopify-cli/pull/1722): Fix `theme serve` failing when the port is already being used
* [#1751](https://github.com/Shopify/shopify-cli/pull/1751): A bug in the app creation flow that caused the CLI to abort when the form validation failed.
* [#1750](https://github.com/Shopify/shopify-cli/pull/1750): Runtime errors in Windows' environments when the `PATHEXT` environment variable is not defined.
* [#1758](https://github.com/Shopify/shopify-cli/pull/1758): Fix tunnel creation for expired anonymous tunnels

## Version 2.7.0 - 2021-11-15

### Changed
* [#1650](https://github.com/Shopify/shopify-cli/pull/1650): **Breaking** Move app commands under `shopify app`.

### Fixed
* [#1714](https://github.com/Shopify/shopify-cli/pull/1714): Fix theme serve not serving assets locally when two URLs are on the same line
* [#1729](https://github.com/Shopify/shopify-cli/pull/1729): Update theme-check to 1.8.0

## Version 2.6.6
### Added
* [#1609](https://github.com/Shopify/shopify-cli/pull/1609): Add `--http-bind=HOST` option to `shopify theme serve`.

### Fixed
* [#1678](https://github.com/Shopify/shopify-cli/pull/1678): Fix migrator's incompatibility with Ruby 2.5.
* [#1690](https://github.com/Shopify/shopify-cli/pull/1690): Fix `extension push` command for `PRODUCT_SUBSCRIPTION` extensions

### Changed
* [#1678](https://github.com/Shopify/shopify-cli/pull/1678): Change the `@shopify/scripts-checkout-apis-temp` package name to `@shopify/scripts-discount-apis`.

### Removed
* [#1664](https://github.com/Shopify/shopify-cli/pull/1664): Remove ruby-locking extension
## Version 2.6.5
### Fixed
* [#1661](https://github.com/Shopify/shopify-cli/pull/1661): Handle npm list non-zero exit status when pushing scripts
## Version 2.6.4
### Fixed
* [#1633](https://github.com/Shopify/shopify-cli/pull/1633): Runtime error when the shop passed on login is invalid
* [#1625](https://github.com/Shopify/shopify-cli/pull/1625): Fix push bug with post-purchase extensions

### Added
* [#1542](https://github.com/Shopify/shopify-cli/pull/1542): Add option theme serve --poll to force polling when watching files
* [#1635](https://github.com/Shopify/shopify-cli/pull/1635): Command to enable or disable anonymous usage and error reporting.
* [#1614](https://github.com/Shopify/shopify-cli/pull/1614): Add ability to set custom ngrok port for all app serve commands.
### Removed

### Changed
* [#1635](https://github.com/Shopify/shopify-cli/pull/1635): Automatic usage and error reporting configuration has been unified under `analytics.enabled`.

### Security

## Version 2.6.3
* Enable error-reporting.

## Version 2.6.2
* Fix broken installation due to a missing variable in `extconf.rb`

## Version 2.6.1
* [#1608](https://github.com/Shopify/shopify-cli/pull/1608): Fix errors not being reported.
## Version 2.6.0
* [#1574](https://github.com/Shopify/shopify-cli/pull/1574): Hide LoadError for ${RUBY_MAJOR}/ffi_c.
* [#1567](https://github.com/Shopify/shopify-cli/pull/1567): Add ability to set custom port for ngrok tunnel in node serve.
* [#1584](https://github.com/Shopify/shopify-cli/issues/1584): Fixed extended help message not showing.
* [#1566](https://github.com/Shopify/shopify-cli/pull/1566): Fix bug when running `npm | yarn list` for extension package resolution.
* [#1524](https://github.com/Shopify/shopify-cli/pull/1524): Add automatic error-reporting.
* [#1528](https://github.com/Shopify/shopify-cli/pull/1528): Bump theme-check version to 1.7
* [#1566](https://github.com/Shopify/shopify-cli/pull/1566): Fix bug when running `npm | yarn list` for extension package resolution

## Version 2.5.0
* [#1553](https://github.com/Shopify/shopify-cli/pull/1553): Add support for PHP app projects

## Version 2.4.0
* [#1488](https://github.com/Shopify/shopify-cli/pull/1488): Update theme-check to 1.4
* [#1507](https://github.com/Shopify/shopify-cli/pull/1507): Limit the generated name for themes to 50 characters

## Version 2.3.0
* [#1386](https://github.com/Shopify/shopify-cli/pull/1386): Update theme-check to 1.2
* [#1457](https://github.com/Shopify/shopify-cli/pull/1457): Fix uploading of binary theme files under Windows
* [#1480](https://github.com/Shopify/shopify-cli/pull/1480): Fix customers pages not working with `theme serve`
* [#1479](https://github.com/Shopify/shopify-cli/pull/1479): Add theme push & pull option to ignore files per command
v
## Version 2.2.2
* [1382](https:/github.com/Shopify/shopify-cli/pull/1382): Client side module upload for Scripts

## Version 2.2.1
* [1432](https://github.com/Shopify/shopify-cli/pull/1432) New method for determining renderer package name

## Version 2.2.0
* [#1424](https//github.com/Shopify/shopify-cli/pull/1424/): Add `--resourceUrl` flag to extension serve command
* [#1419](https://github.com/Shopify/shopify-cli/pull/1419): Remove analytics prompt when used in CI
* [#1418](https://github.com/Shopify/shopify-cli/pull/1418): Auto configure resource URL for Checkout Extensions
* [#1399](https://github.com/Shopify/shopify-cli/pull/1399): Fix error when running `shopify extension serve` in a theme app extension project

## Version 2.1.0
* [#1357](https//github.com/Shopify/shopify-cli/pull/1357): Update Theme-Check to 1.1
* [#1352](https://github.com/Shopify/shopify-cli/pull/1352): Add `shopify extension check` for checking theme app extensions
* [#1304](https://github.com/Shopify/shopify-cli/pull/1304): Prompt user to run `shopify extension connect` if .env file is missing

## Version 2.0.2
* [#1305](https//github.com/Shopify/shopify-cli/pull/1305): Fix `Uninitialized constant Net::WriteTimeout` error
* [#1319](https://github.com/Shopify/shopify-cli/pull/1319): Fix `theme pull` not pulling some files
* [#1321](https://github.com/Shopify/shopify-cli/pull/1321): Fix error when pulling images with `theme pull`
* [#1322](https://github.com/Shopify/shopify-cli/pull/1322): Fix error when running `shopify theme language-server --help`
* [#1324](https://github.com/Shopify/shopify-cli/pull/1324): Fix issue [#1308](https://github.com/Shopify/shopify-cli/issues/1308) where a non-English language on Partner Account breaks how CLI determines latest API version.
* [#1343](https://github.com/Shopify/shopify-cli/pull/1343): Fix inconsistent use of periods vs ellipsis in messages. This replaces periods with ellipsis.

## Version 2.0.1
* [#1295](https//github.com/Shopify/shopify-cli/pull/1295): Ignore files at the root of a theme app extension project
* [#1296](https://github.com/Shopify/shopify-cli/pull/1296): Fix issue [#1294](https://github.com/Shopify/shopify-cli/issues/1294) regarding call to Windows `start` command with URL.
* [#1298](https://github.com/Shopify/shopify-cli/pull/1298): Fix error in `theme serve` command
* [#1301](https://github.com/Shopify/shopify-cli/pull/1301): Add `theme init` command

## Version 2.0.0
* Adds support or theme development
* Changes to command structure (note that these are breaking changes, see [README](README.md))
* Checkout the [apps](https://shopify.dev/apps/tools/cli) and [themes](https://shopify.dev/themes/tools/cli) sections of the new [shopify.dev](https://shopify.dev) after Unite 2021 (June 29).

## Version 1.14.0
* [#1275](https://github.com/Shopify/shopify-cli/pull/1275): Use script.json to specify script metadata
* [#1279](https://github.com/Shopify/shopify-cli/pull/1279): Fix bug where a script push still fails after the user answers the force push prompt
* [#1288](https://github.com/Shopify/shopify-cli/pull/1288): Fix bug where Scripts SDK was included for projects that don't require it

## Version 1.13.1
* [#1274](https://github.com/Shopify/shopify-cli/pull/1274): Only print api_key during error if it exists
* [#1272](https://github.com/Shopify/shopify-cli/pull/1272): Fix minor bug with extension serve for UI extensions

## Version 1.13.0
* [#1266](https://github.com/Shopify/shopify-cli/pull/1266): Developer Console release
* [#1265](https://github.com/Shopify/shopify-cli/pull/1265): Fix bug where commands hang after an unsuccessful authentication

## Version 1.12.0
* [#1255](https://github.com/Shopify/shopify-cli/pull/1255): Fix beta flag checks when running `shopify serve`

## Version 1.11.0
* [#1221](https://github.com/Shopify/shopify-cli/pull/1221): Prioritizes returning an HTTPS URL over HTTP from `shopify tunnel status`.
* [#1223](https://github.com/Shopify/shopify-cli/pull/1233): Running `shopify serve` in an extension project now automatically runs `shopify tunnel`.
* [#1225](https://github.com/Shopify/shopify-cli/pull/1225): Improved handling of "account not found" scenario, plus improvements to related tests and UX messaging
* [#1229](https://github.com/Shopify/shopify-cli/pull/1229): Allows Checkout Extensions to specify configuration attributes in their extension.config.yml file.
* [#1238](https://github.com/Shopify/shopify-cli/pull/1238): Auto Tunnel Support for Checkout Extension
* [#1256](https://github.com/Shopify/shopify-cli/pull/1256): Allow using spaces around the equal sign on .env file.

## Version 1.10.0
* Updating internal features in development

## Version 1.9.1
* [#1201](https://github.com/Shopify/shopify-cli/pull/1201) Determine Argo Renderer Dynamically. This fixes `shopify serve` and `shopify push` for extensions.

## Version 1.9.0
* [#1181](https://github.com/Shopify/shopify-cli/pull/1181): Remove the subcommand references of the `generate` command for node apps (fixes [1176](https://github.com/Shopify/shopify-cli/issues/1176))

## Version 1.8.0
* [#1119](https://github.com/Shopify/shopify-cli/pull/1119): Enable guest serialization for scripts

## Version 1.7.1

* Updating internal features in development

## Version 1.7.0
* [#1109](https://github.com/Shopify/shopify-cli/pull/1109): Abort app generation if name contains disallowed text.
* [#1075](https://github.com/Shopify/shopify-cli/pull/1075): Add support for kebab-case flags

## Version 1.6.0
* [#1049](https://github.com/Shopify/shopify-cli/pull/1049): Add schema versioning support to the script project type
* [#1059](https://github.com/Shopify/shopify-cli/pull/1059): Remove the functionality of the `generate` command for node apps, since it will no longer be feasible with the new node library
* [#1046](https://github.com/Shopify/shopify-cli/pull/1046): Include a vendored copy of Webrick, as it's no longer included in Ruby 3.
* [#1041](https://github.com/Shopify/shopify-cli/pull/1041): Remove unnecessary shell call to `spring stop`. We already pass `--skip-spring` when creating the app so running `spring stop` would have no effect.
* [#1034](https://github.com/Shopify/shopify-cli/pull/1034): Abort if a system call fails.

## Version 1.5.0
* [#965](https://github.com/Shopify/shopify-cli/pull/965): Remove --no-optional when using npm to create new project
* [#958](https://github.com/Shopify/shopify-cli/pull/958): Split `connect` command into project-specific functionality
* [#992](https://github.com/Shopify/shopify-cli/pull/992): Add Theme Kit functionality to CLI

## Version 1.4.1

* [#917](https://github.com/Shopify/shopify-cli/pull/917): Ensure analytics for create action includes the same fields as other commands

## Version 1.4.0

* Updates to tests, dependencies and internal tooling
* [#924](https://github.com/Shopify/shopify-cli/pull/924): Improve debugging messages on Partner API errors

## Version 1.3.1

* Allow any characters in ngrok account names

## Version 1.3.0
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

## Version 1.1.0
* Add native Windows 10 support, including variety of stability fixes.

## Version 1.0.5
* Fix a bug in out opt-in metrics

## Version 1.0.4
* Fix a bug when running the `connect` command with an account with multiple organizations

## Version 1.0.3
* Fix a bug which causes an error in the `populate` and `generate` commands when prompting for the shop name

## Version 1.0.2
* Fix missing shop parameter to AdminAPI.query() call (impacting populate and generate commands)

## Version 1.0.1
* Fixed an issue with RVM taking over the shell shim fd when it was not in use

## Version 1.0.0
* Release the installer-based version of the CLI

## Version 0.9.3 - Internal Test Version
* Rebased to master
* Removed auto-generated files from builds directory

## Version 0.9.2 - Internal Test Version
* Rebased to master, to pull in 7+ Pull Requests
* Updates to dependencies to package files (updated Ruby version)

## Version 0.9.1 - Internal Test Version
* Updated required Ruby version for the CLI
* Minor fixes for the build / release process

## Version 0.9.0 - Internal Test Version

* Initial test release of gem-based CLI
