Feature: The release process

  Scenario: The Ruby gem contains the ISSUE_TEMPLATE needed by some features
    Given I have a VM with the CLI and a working directory
    And I build the Ruby Gem as shopify-cli.gem
    When I install the Ruby Gem shopify-cli.gem
    Then The shopify-cli.gem Ruby Gem contains a file .github/ISSUE_TEMPLATE.md  