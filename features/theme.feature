Feature: The theme command

  Scenario: The user wants to build and check a theme
    Given I have a working directory
    When I create a theme named MyTheme
    Then I should be able to check the theme in directory MyTheme 