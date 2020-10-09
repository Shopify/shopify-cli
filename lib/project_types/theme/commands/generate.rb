# frozen_string_literal: true
require 'shopify_cli'

module Theme
  module Commands
    class Generate < ShopifyCli::Command
      subcommand :Env, 'env', Project.project_filepath('commands/generate/env')

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        ShopifyCli::Context.message('theme.generate.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
