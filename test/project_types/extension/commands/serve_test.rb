# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCli::ProjectType.load_type("extension")
        ExtensionTestHelpers.fake_extension_project(with_mocks: true)
      end

      def test_defers_serving_to_the_specification_handler
        serve = ::Extension::Commands::Serve.new(@context)
        serve.specification_handler.expects(:serve)
        serve.call([], "serve")
      end

      def test_error_raised_if_no_available_ports_found
        serve = ::Extension::Commands::Serve.new(@context)

        socket = mock.tap { |s| s.expects(:close).times(25) }
        25.times do |i|
          port = ::Extension::Commands::Serve::DEFAULT_PORT + i
          Socket.expects(:tcp).with("localhost", port, connect_timeout: 1).yields(socket).returns(false)
        end

        error = assert_raises ShopifyCli::Abort do
          serve.call([], "serve")
        end

        assert_includes error.message, @context.message("serve.no_available_ports_found")
      end
    end
  end
end
