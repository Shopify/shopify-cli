# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy < ShopifyCli::Command
      def call(args, _name)
      end

      def self.help
        <<~HELP
          Deploy your app to a service
          Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy <service>}}
          Example: {{command:#{ShopifyCli::TOOL_NAME} deploy heroku}}
        HELP
      end
    end
  end
end
