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
        stub_specification_handler_options(serve)
        serve.specification_handler.expects(:serve)
        serve.call([], "serve")
      end

      def test_error_raised_if_specification_handler_supports_choosing_port_but_no_ports_available
        serve = ::Extension::Commands::Serve.new(@context)

        Tasks::ChooseNextAvailablePort.expects(:call)
          .with(from: ::Extension::Commands::Serve::DEFAULT_PORT)
          .returns(ShopifyCli::Result.failure(ArgumentError))
          .once
        serve.specification_handler.expects(:choose_port?).returns(true).once

        error = assert_raises ShopifyCli::Abort do
          serve.call([], "serve")
        end

        assert_includes error.message, @context.message("serve.no_available_ports_found")
      end

      def test_port_not_chosen_if_specification_handler_does_not_support_chosen_port
        serve = ::Extension::Commands::Serve.new(@context)
        stub_specification_handler_options(serve)
        Tasks::ChooseNextAvailablePort.expects(:call).never
        serve.specification_handler.expects(:serve).once
        serve.call([], "serve")
      end

      def test_new_tunnel_started_if_specification_handler_supports_establish_tunnel
        serve = ::Extension::Commands::Serve.new(@context)
        stub_specification_handler_options(serve, choose_port: true, establish_tunnel: true)
        ShopifyCli::Tunnel.expects(:start)
          .with(@context, port: Extension::Commands::Serve::DEFAULT_PORT)
          .returns("ngrok.example.com")
          .once
        serve.specification_handler.expects(:serve).once
        serve.call([], "serve")
      end

      def test_tunnel_not_started_if_specification_handler_does_not_support_establish_tunnel
        serve = ::Extension::Commands::Serve.new(@context)
        stub_specification_handler_options(serve)
        ShopifyCli::Tunnel.expects(:start).never
        serve.specification_handler.expects(:serve).once
        serve.call([], "serve")
      end

      private

      def stub_specification_handler_options(serve, choose_port: false, establish_tunnel: false)
        serve.specification_handler.expects(:choose_port?).returns(choose_port).once
        serve.specification_handler.expects(:establish_tunnel?).returns(establish_tunnel).once
      end
    end
  end
end
