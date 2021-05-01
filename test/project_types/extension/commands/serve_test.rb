# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TempProjectSetup

      def setup
        super
        ShopifyCli::ProjectType.load_type("extension")
        setup_temp_project
      end

      def test_defers_serving_to_the_specification_handler
        serve = ::Extension::Commands::Serve.new(@context)
        serve.specification_handler.expects(:serve)
        serve.call([], "serve")
      end
    end
  end
end
