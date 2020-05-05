module Extension
  module Content
    module Create
      ASK_NAME = 'Extension name'
      INVALID_NAME = "Extension name must be under %s characters"

      ASK_TYPE = 'What type of extension would you like to create?'
      INVALID_TYPE = 'Invalid extension type.'

      ASK_APP = 'Which app would you like to associate with the extension?'
      NO_APPS = 'You don’t have any apps. Learn more about building apps at <https://shopify.dev/concepts/apps> or try creating one using a new app using {{command:shopify create app}}.'
      INVALID_API_KEY = 'The API key %s does not match any of your apps.'

      READY_TO_START = 'You\'re ready to start building %s! Try running `shopify serve` to start a local server.'
      LEARN_MORE = 'Learn more about building %s extensions at <shopify.dev>'
    end

    module Pack
      FRAME_TITLE = "Packing extension with: %s..."

      BUILD_FAILURE_MESSAGE = 'Failed to pack extension code for deployment.'
    end

    module Push
      FRAME_TITLE = 'Pushing your extension to Shopify'
      WAITING_TEXT = 'Pushing to Shopify...'

      CREATE_CONFIRM_INFO = 'This will create an extension on the Partners Dashboard. You can only create one subscription management extension per app.'
      CREATE_CONFIRM_QUESTION = 'This is not reversible (y/n)'
      CREATE_ABORT = 'Pushing extension aborted by user.'

      SUCCESS_CONFIRMATION = '{{v}} Extension has been pushed to a draft.'
      SUCCESS_INFO = '{{*}} Visit the Partner\'s Dashboard to create and publish versions.'
    end

    module Serve
      FRAME_TITLE = 'Running your extension'

      SERVE_FAILURE_MESSAGE = 'Failed to run extension code for testing.'
    end
  end
end
