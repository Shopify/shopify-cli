Feature: The release process

  Scenario: The Ruby gem contains the ISSUE_TEMPLATE needed by some features
    Given I have a working directory
    When I build the Ruby Gem as shopify.gem
    Then The shopify.gem Ruby Gem contains a file .github/ISSUE_TEMPLATE.md  