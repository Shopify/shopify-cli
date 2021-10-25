# Contributing

This documents includes guidelines for contributors.

## Testing

The project employs a diverse suite tests that help ensure it works as intended and prevents regressions as it continues to grow and evolve.

### Unit Tests
Most of the internal components the project uses have unit tests to thoroughly test them. Here dependencies of components are mocked or stubbed appropriately to ensure tests are reliable, test only one component and are fast!

### Acceptance Tests

Acceptance tests run the built `shopify` command line against a wide range of fixtures and verify its output and results. They are the slowest to run however provide the most coverage. The idea is to test a few complete scenarios for each major feature.

Those are written in [Cucumber](https://cucumber.io/) and Ruby and can be found in the [`features/`](/features) directory. They can be executed by running:

```bash
bundle exec cucumber
bundle exec cucumber features/theme.feature:3 # A specific test
```

> **Note** that we currently don't have an approach for stubbing the interactions with the GraphQL APIs and that therefore we can't write acceptance tests for commands that interact with APIs.

#### Debugging acceptance tests
When developing acceptance tests, it can be helpful to see the outputs of running commands.
To see outputs, append `--verbose` when running an acceptance test. Example:

```sh
bundle exec cucumber features/theme.feature --verbose
```