# frozen_string_literal: true

module Extension
  module Content
    module Create
      ASK_NAME = 'Extension name'
      INVALID_NAME = "Extension name must be under %s characters"

      ASK_TYPE = 'What type of extension are you creating?'
      INVALID_TYPE = 'Extension type is invalid.'

      SETUP_PROJECT_FRAME_TITLE = 'Initializing Project'

      READY_TO_START = "{{*}} You’re ready to start building {{green:%s}}!\nA new folder was generated at {{green:./%s}}. Navigate there, then run {{command:shopify serve}} to start a local server."
      LEARN_MORE = '{{*}} Register this extension with one of your apps by running {{command:shopify register}}.'
    end

    module Build
      FRAME_TITLE = "Building extension with: %s..."

      BUILD_FAILURE_MESSAGE = 'Failed to build extension code.'
    end

    module Register
      FRAME_TITLE = 'Registering Extension'
      WAITING_TEXT = 'Registering with Shopify...'

      ALREADY_REGISTERED = 'Extension is already registered.'

      LOADING_APPS = 'Loading your apps...'
      ASK_APP = 'Which app would you like to register this extension with?'
      NO_APPS = '{{x}} You don’t have any apps.'
      LEARN_ABOUT_APPS = '{{*}} Learn more about building apps at <https://shopify.dev/concepts/apps>, or try creating a new app using {{shopify create app.}}'
      INVALID_API_KEY = 'The API key %s does not match any of your apps.'

      CONFIRM_INFO = 'You can only create one %s extension per app, which can’t be undone.'
      CONFIRM_QUESTION = 'Would you like to register this extension with {{green:%s}}? (y/n)'
      CONFIRM_ABORT = 'Extension was not created.'

      SUCCESS = '{{v}} Registered {{green:%s}} with {{green:%s}}.'
      SUCCESS_INFO = '{{*}} Run {{command:shopify push}} to push your extension to Shopify.'
    end

    module Push
      FRAME_TITLE = 'Pushing your extension to Shopify'
      WAITING_TEXT = 'Pushing code to Shopify...'

      SUCCESS_CONFIRMATION = '{{v}} Pushed %s to a draft on %s.'
      SUCCESS_INFO = '{{*}} Visit <extension URL> to version and publish your extension.'
    end

    module Serve
      FRAME_TITLE = 'Serving extension...'

      SERVE_FAILURE_MESSAGE = 'Failed to run extension code.'
    end

    module Tunnel
      MISSING_TOKEN = '{{x}} {{red:auth requires a token argument}}. Find it on your ngrok dashboard: {{underline:https://dashboard.ngrok.com/auth/your-authtoken}}.'
      INVALID_PORT = '%s is not a valid port.'
    end

    module Models
      TYPES = {
        ARGO: {
          missing_file_error: 'Could not find built extension file.',
          script_prepare_error: 'An error occurred while attempting to prepare your script.'
        },
        Extension::Models::Types::SubscriptionManagement::IDENTIFIER => {
          name: 'Subscription Management',
          tagline: '(limit 1 per app)',
        },
        Extension::Models::Types::CheckoutPostPurchase::IDENTIFIER => {
          name: 'Checkout Post Purchase',
          tagline: '',
        }
      }
    end
  end
end
