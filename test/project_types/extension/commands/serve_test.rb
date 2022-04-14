# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCLI::ProjectType.load_type("extension")
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call)
        ExtensionTestHelpers.fake_extension_project(with_mocks: true)
      end

      def test_defers_serving_to_the_specification_handler
        serve = ::Extension::Command::Serve.new(@context)
        stub_specification_handler_options(serve)
        serve.specification_handler.expects(:serve)
        serve.call([], "serve")
      end

      def test_error_raised_if_specification_handler_supports_choosing_port_but_no_ports_available
        serve = ::Extension::Command::Serve.new(@context)

        Tasks::ChooseNextAvailablePort.expects(:call)
          .with(from: ::Extension::Command::Serve::DEFAULT_PORT)
          .returns(ShopifyCLI::Result.failure(ArgumentError))
          .once
        serve.specification_handler.expects(:choose_port?).returns(true).once

        error = assert_raises ShopifyCLI::Abort do
          serve.call([], "serve")
        end

        assert_includes error.message, @context.message("serve.no_available_ports_found")
      end

      def test_port_not_chosen_if_specification_handler_does_not_support_chosen_port
        serve = ::Extension::Command::Serve.new(@context)
        stub_specification_handler_options(serve)
        Tasks::ChooseNextAvailablePort.expects(:call).never
        serve.specification_handler.expects(:serve).once
        serve.call([], "serve")
      end

      def test_new_tunnel_started_if_tunnel_supported_and_requirements_met
        serve = ::Extension::Command::Serve.new(@context)
        stub_specification_handler_options(serve, choose_port: true, establish_tunnel: true)
        Tasks::ChooseNextAvailablePort.expects(:call)
          .returns(ShopifyCLI::Result.success(Extension::Command::Serve::DEFAULT_PORT))
        ShopifyCLI::Tunnel.expects(:urls).returns(["https://shopify.ngrok.io"])
        ShopifyCLI::Tunnel.expects(:running_on?).returns(true)
        ShopifyCLI::Tunnel.expects(:start)
          .with(@context, port: Extension::Command::Serve::DEFAULT_PORT)
          .returns("ngrok.example.com")
          .once

        serve.specification_handler.expects(:serve).once
        serve.call([], "serve")
      end

      def test_new_tunnel_started_if_tunnel_supported_and_no_tunnels_running
        serve = ::Extension::Command::Serve.new(@context)
        stub_specification_handler_options(serve, choose_port: true, establish_tunnel: true)
        Tasks::ChooseNextAvailablePort.expects(:call)
          .returns(ShopifyCLI::Result.success(Extension::Command::Serve::DEFAULT_PORT))
        ShopifyCLI::Tunnel.expects(:urls).returns([])
        ShopifyCLI::Tunnel.expects(:start)
          .with(@context, port: Extension::Command::Serve::DEFAULT_PORT)
          .returns("ngrok.example.com")
          .once

        serve.specification_handler.expects(:serve).once
        serve.call([], "serve")
      end

      def test_serve_quits_if_tunnel_requested_but_tunnel_already_running_on_different_port
        serve = ::Extension::Command::Serve.new(@context)
        stub_specification_handler_options(serve, choose_port: true, establish_tunnel: true)
        ShopifyCLI::Tunnel.expects(:urls).returns(["https://shopify.ngrok.io"])
        ShopifyCLI::Tunnel.expects(:running_on?).returns(false)

        error = assert_raises ShopifyCLI::Abort do
          serve.call([], "serve")
        end

        assert_includes error.message, @context.message("serve.tunnel_already_running")
      end

      def test_tunnel_not_started_if_specification_handler_does_not_support_establish_tunnel
        serve = ::Extension::Command::Serve.new(@context)
        stub_specification_handler_options(serve)
        ShopifyCLI::Tunnel.expects(:start).never
        serve.specification_handler.expects(:serve).once
        serve.call([], "serve")
      end

      def test_resource_url_is_forwarded_to_specification_handler_if_one_is_provided
        serve = ::Extension::Command::Serve.new(@context)
        expected_resource_url = "foo/bar"
        stub_specification_handler_options(serve, choose_port: true)

        serve.specification_handler
          .expects(:serve)
          .with(context: @context, tunnel_url: nil, port: 39351, resource_url: expected_resource_url)
        serve.options.flags[:resource_url] = expected_resource_url
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
