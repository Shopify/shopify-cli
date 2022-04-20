# frozen_string_literal: true
require "theme_check"

module Theme
  class Command
    class Check < ShopifyCLI::Command::SubCommand
      recommend_default_ruby_range

      class Options < ShopifyCLI::Options
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
        @theme_check.run!
      rescue ThemeCheck::Cli::Abort, ThemeCheck::ThemeCheckError => e
        raise ShopifyCLI::Abort,
          ShopifyCLI::Context.message("theme.check.error", e.full_message)
      end

      def self.help
        ShopifyCLI::Context.message("theme.check.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
