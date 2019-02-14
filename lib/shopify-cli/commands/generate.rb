# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate < ShopifyCli::Command
      def call(args, _name)
      end

      def self.help
        <<~HELP
          Generate test data for your shop
          Usage: {{command:#{ShopifyCli::TOOL_NAME} generate <datatype> --count=<n>}}
          Example: {{command:#{ShopifyCli::TOOL_NAME} generate orders --count=10}}
        HELP
      end
    end
  end
end
