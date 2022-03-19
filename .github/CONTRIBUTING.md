# How to contribute

Shopify CLI is an open source project. We want to make it as easy and transparent as possible to contribute. If we are missing anything or can make the process easier in any way, please let us know by [opening an issue](https://github.com/Shopify/shopify-cli/issues/new).

## Code of conduct

We expect all participants to read our [code of conduct](https://github.com/Shopify/shopify-cli/blob/main/.github/CODE_OF_CONDUCT.md) to understand which actions are and aren’t tolerated.

## Open development

All work on Shopify CLI happens directly on GitHub. Both team members and external contributors send pull requests which go through the same review process.

## Design guidelines
When contributing to the Shopify CLI, there are a set of [design guidelines](https://github.com/Shopify/shopify-cli/blob/main/.github/DESIGN.md) that should be followed. The design guidelines are meant to help create a consistent and predictable experience for all users of the tool, and help make descisions quicker when creating new commands or adding to existing ones.

## Bugs

### Where to find known issues

We track all of our issues in GitHub and [bugs](https://github.com/Shopify/shopify-cli/labels/type:bug) are labeled accordingly. If you are planning to work on an issue, avoid ones which already have an assignee, where someone has commented within the last two weeks they are working on it, or the issue is labeled with [fix in progress](https://github.com/Shopify/shopify-cli/labels/fix%20in%20progress). We will do our best to communicate when an issue is being worked on internally.

### Running against a local environment

This section only applies to Shopify staff:

To run against a local Partners or Identity instance, you can use:

`SHOPIFY_APP_CLI_LOCAL_PARTNERS=1 shopify`

### Reporting new issues

To reduce duplicates, look through open issues before filing one. When [opening an issue](https://github.com/Shopify/shopify-cli/issues/new?template=ISSUE.md), complete as much of the template as possible.


## Your first pull request

Working on your first pull request? You can learn how from this free video series:

[How to Contribute to an Open Source Project on GitHub](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github)

To help you get familiar with our contribution process, we have a list of [good first issues](https://github.com/Shopify/shopify-cli/labels/good%20first%20issue) that contain bugs with limited scope. This is a great place to get started.

If you decide to fix an issue, please check the comment thread in case somebody is already working on a fix. If nobody is working on it, leave a comment stating that you intend to work on it.

If somebody claims an issue but doesn’t follow up for more than two weeks, it’s fine to take it over but still leave a comment stating that you intend to work on it.

### Sending a pull request

We’ll review your pull request and either merge it, request changes to it, or close it with an explanation. We’ll do our best to provide updates and feedback throughout the process.

### Contributor License Agreement (CLA)

Each contributor is required to [sign a CLA](https://cla.shopify.com/). This process is automated as part of your first pull request and is only required once. If any contributor has not signed or does not have an associated GitHub account, the CLA check will fail and the pull request is unable to be merged.

## Releasing a new version

If you are changing the CLI version, please make sure to update all the places that use it:
* ShopifyCLI::VERSION
* Debian package version under `packaging/debian`
