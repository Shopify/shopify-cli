# frozen_string_literal: true
require "theme_check"

module Theme
  class Command
    class LanguageServer < ShopifyCli::SubCommand
      def call(*)
        ThemeCheck::LanguageServer.start
      end

      def self.help
        ShopifyCli::Context.message("theme.language_server.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
