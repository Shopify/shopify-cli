Feature: The installation process

  Scenario: The extensions native package is pulled as part of the installation
    Given I have a working directory
    When Shopify extensions are installed in the working directory
    Then I have the right binary for my system's architecture

  Scenario: The user installs Shopify CLI
    Given Shopify CLI is installed on my system
    Then The file `ISSUE_TEMPLATE.md` is retained inside `.github`