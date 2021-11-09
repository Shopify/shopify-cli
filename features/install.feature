Feature: The installation process

  Scenario: The extensions native package is pulled as part of the installation
    Given I have a working directory
    When Shopify extensions are installed in the working directory
    Then I have the right binary for my system's architecture