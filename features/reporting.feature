Feature: The installation process

  Scenario: The user enables reporting
     Given I have a VM with the CLI and a working directory
     Then I can turn the reporting on

  Scenario: The user disables reporting
     Given I have a VM with the CLI and a working directory
     Then I can turn the reporting off