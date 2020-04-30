# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    module Types
      class SubscriptionManagement < Models::Type
        IDENTIFIER = 'SUBSCRIPTION_MANAGEMENT'
        SCRIPT_PATH = %w(build main.js)

        def config(context)
          filepath = File.join(context.root, SCRIPT_PATH)
          context.abort(get_content(:missing_file_error)) unless File.exists?(filepath)

          begin
            {
              serialized_script: Base64.strict_encode64(File.open(filepath).read.chomp)
            }
          rescue Exception
            context.abort(get_content(:script_prepare_error))
          end
        end
      end
    end
  end
end
