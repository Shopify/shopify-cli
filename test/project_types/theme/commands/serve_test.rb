# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_serve_command
        context = ShopifyCli::Context.new
        Themekit.expects(:ensure_themekit_installed).with(context)
        Themekit.expects(:serve).with(context)

        Theme::Commands::Serve.new(context).call
      end
    end
  end
end
