Feature: The version command

  Scenario: The Ruby Gem is installed in a Linux environment
    Given I have a VM with the CLI and a working directory
    And I build the Ruby Gem as shopify-cli.gem
    When I install the Ruby Gem shopify-cli.gem
    Then I can run "shopify version" successfully

  Scenario: The user wants to know the version of the CLI
   Given I have a VM with the CLI and a working directory
    Then 'version' returns the right version