# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module Types
      class SubscriptionManagement < Models::Type
        SCRIPT_PATH = %w(build main.js)

        MISSING_FILE_ERROR = 'Could not find built extension file.'
        SCRIPT_PREPARE_ERROR = 'An error occurred while attempting to prepare your script.'


        def identifier
          'SUBSCRIPTION_MANAGEMENT'
        end

        def name
          'Subscription Management'
        end

        def config(context)
          filepath = File.join(context.root, SCRIPT_PATH)
          context.abort(MISSING_FILE_ERROR) unless File.exists?(filepath)

          begin
            {
              serialized_script: Base64.strict_encode64(File.open(filepath).read.chomp)
            }
          rescue Exception
            context.abort(SCRIPT_PREPARE_ERROR)
          end
        end
      end
    end
  end
end
