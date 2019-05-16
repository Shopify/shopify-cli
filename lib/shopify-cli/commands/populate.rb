require 'shopify_cli'

module ShopifyCli
  module Commands
    class Populate < ShopifyCli::Command
      def call
        puts CLI::UI.fmt(self.class.mock)
      end

      def self.mock
        <<~MOCK
          Store populated with 50 products, customers and order records.
        MOCK
      end

      def self.help
        <<~HELP
          Populate dev store with products, customers and order records.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} populate <storename>}}
        HELP
      end
    end
  end
end
