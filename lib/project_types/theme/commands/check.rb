# frozen_string_literal: true
require "theme_check"

module Theme
  class Command
    class Check < ShopifyCli::SubCommand
      class Options < ShopifyCli::Options
        def initialize(theme_check)
          super()
          @theme_check = theme_check
        end

        def parse(_options_block, args)
          @theme_check.parse(args)
        end
      end

      def initialize(*)
        super
        @theme_check = ThemeCheck::Cli.new
        self.options = Options.new(@theme_check)
      end

      def call(*)
        @theme_check.run
      end

      def self.help
        ShopifyCli::Context.message("theme.check.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
