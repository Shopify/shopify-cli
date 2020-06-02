# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Messages
    MESSAGES = {
      create: {
        ask_name: 'Extension name',
        invalid_name: 'Extension name must be under %s characters',
        ask_type: 'What type of extension are you creating?',
        invalid_type: 'Extension type is invalid.',
        setup_project_frame_title: 'Initializing Project',
        ready_to_start: '{{*}} You’re ready to start building {{green:%s}}!\nA new folder was generated at {{green:./%s}}. Navigate there, then run {{command:shopify serve}} to start a local server.',
        learn_more: '{{*}} Register this extension with one of your apps by running {{command:shopify register}}.',
      },
      build: {
        frame_title: 'Building extension with: %s...',
        build_failure_message: 'Failed to build extension code.',
      },
      register: {
        frame_title: 'Registering Extension',
        waiting_text: 'Registering with Shopify...',
        already_registered: 'Extension is already registered.',
        loading_apps: 'Loading your apps...',
        ask_app: 'Which app would you like to register this extension with?',
        no_apps: '{{x}} You don’t have any apps.',
        learn_about_apps: '{{*}} Learn more about building apps at <https://shopify.dev/concepts/apps>, or try creating a new app using {{shopify create app.}}',
        invalid_api_key: 'The API key %s does not match any of your apps.',
        confirm_info: 'You can only create one %s extension per app, which can’t be undone.',
        confirm_question: 'Would you like to register this extension with {{green:%s}}? (y/n)',
        confirm_abort: 'Extension was not created.',
        success: '{{v}} Registered {{green:%s}} with {{green:%s}}.',
        success_info: '{{*}} Run {{command:shopify push}} to push your extension to Shopify.',
      },
      push: {
        frame_title: 'Pushing your extension to Shopify',
        waiting_text: 'Pushing code to Shopify...',
        success_confirmation: '{{v}} Pushed %s to a draft at %s.',
        success_info: '{{*}} Visit <extension URL> to version and publish your extension.',
      },
      serve: {
        frame_title: 'Serving extension...',
        serve_failure_message: 'Failed to run extension code.',
      },
      tunnel: {
        missing_token: '{{x}} {{red:auth requires a token argument}}. Find it on your ngrok dashboard: {{underline:https://dashboard.ngrok.com/auth/your-authtoken}}.',
        invalid_port: '%s is not a valid port.'
      },
      features: {
        argo: {
          missing_file_error: 'Could not find built extension file.',
          script_prepare_error: 'An error occurred while attempting to prepare your script.',
        },
      },
      errors: {
        unknown_type: 'Unknown extension type %s'
      }
    }

    TYPES = {
      subscription_management: {
        name: 'Subscription Management',
        tagline: '(limit 1 per app)',
      },
      checkout_post_purchase: {
        name: 'Checkout Post Purchase',
      }
    }
  end
end
