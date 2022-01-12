Feature: The script command

  Scenario: The user wants to create, build, and test a payment methods script
    # Given I have a VM with the CLI and a working directory
    # When I create a payment_methods script named MyPaymentScript
    # Then I should be able to build the script in directory mypaymentscript
    # Then I should be able to test the script in directory mypaymentscript

  Scenario: The user wants to create, build, and test a shipping methods script
    Given I have a VM with the CLI and a working directory
    When I create a shipping_methods script named MyShippingScript
    Then I should be able to build the script in directory myshippingscript
    Then I should be able to test the script in directory myshippingscript