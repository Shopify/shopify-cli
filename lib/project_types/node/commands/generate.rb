# frozen_string_literal: true
require "shopify_cli"

module Node
  module Commands
    class Generate < ShopifyCli::Command
      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        ShopifyCli::Context.message("node.generate.help")
      end

      def self.extended_help
        help
      end
    end
  end
end
