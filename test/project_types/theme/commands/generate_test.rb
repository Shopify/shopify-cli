# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Commands
    class GenerateTest < MiniTest::Test
      def test_puts_help
        ShopifyCli::Context.expects(:message)
          .with('theme.generate.help', ShopifyCli::TOOL_NAME)

        Theme::Commands::Generate.new(@context).call
      end
    end
  end
end
