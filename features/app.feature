Feature: The app command

  Scenario: The user wants to create a rails app
    Given I have a VM with the CLI and a working directory
    When I create a rails app named MyRailsApp in the VM
      Then the app has an environment file with SHOPIFY_API_KEY set to public_api_key
      Then the app has an environment file with SHOPIFY_API_SECRET set to api_secret_key