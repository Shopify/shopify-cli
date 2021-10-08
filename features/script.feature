Feature: The script command

  Scenario: The user wants to create, build, and test a script
    Given I have a VM with the CLI and a working directory
    When I create a payment method script named MyPaymentScript
    Then I should be able to build the script in directory mypaymentscript
    Then I should be able to test the script in directory mypaymentscript