# frozen_string_literal: true
require "test_helper"

module Extension
  module Tasks
    class RunExtensionCommandTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_run_extension_create_succeeds_with_no_errors
        assert_nothing_raised do
          Models::ServerConfig::Extension.expects(:build).with(
            template: "javascript",
            type: "checkout_ui_extension",
            root_dir: "test",
          ).returns(extension)

          server_config = Models::ServerConfig::Root.new(extensions: [extension])

          Models::ServerConfig::Root.expects(:new).returns(server_config).at_least_once

          CLI::Kit::System.expects(:capture3).returns("", nil, true)

          dev_server = Models::DevelopmentServer.new(executable: "fake")
          Models::DevelopmentServer.expects(:new).returns(dev_server) do |server|
            server.expects(:create).with(server_config).returns(true)
          end

          Tasks::RunExtensionCommand.new(
            root_dir: "test",
            template: "javascript",
            type: "checkout_ui_extension",
            command: "create",
            context: context,
          ).call
        end
      end

      def test_run_extension_build_succeeds_with_no_errors
        assert_nothing_raised do
          Models::ServerConfig::Extension.expects(:build).with(
            template: "javascript",
            type: "checkout_ui_extension",
            root_dir: "test",
          ).returns(extension)

          server_config = Models::ServerConfig::Root.new(extensions: [extension])

          Models::ServerConfig::Root.expects(:new).returns(server_config).at_least_once

          dev_server = Models::DevelopmentServer.new(executable: "fake")
          Models::DevelopmentServer.expects(:new).returns(dev_server) do |server|
            server.expects(:build).with(server_config).returns(true)
          end

          CLI::Kit::System.expects(:capture3)
            .with(dev_server.executable, "build", "-", stdin_data: server_config.to_yaml)
            .returns(["", nil, mock(success?: true)])

          Tasks::RunExtensionCommand.new(
            root_dir: "test",
            template: "javascript",
            type: "checkout_ui_extension",
            command: "build",
            context: context,
          ).call
        end
      end

      def test_run_extension_serve_succeeds_with_no_errors
        assert_nothing_raised do
          Models::ServerConfig::Extension.expects(:build).with(
            template: "javascript",
            type: "checkout_ui_extension",
            root_dir: "test",
          ).returns(extension)

          server_config = Models::ServerConfig::Root.new(extensions: [extension])

          Models::ServerConfig::Root.expects(:new).returns(server_config).at_least_once

          dev_server = Models::DevelopmentServer.new(executable: "fake")
          Models::DevelopmentServer.expects(:new).returns(dev_server) do |server|
            server.expects(:build).with(server_config).returns(true)
          end

          CLI::Kit::System.stubs(:popen3).with(dev_server.executable, "serve", "-").returns(nil)

          Tasks::RunExtensionCommand.new(
            root_dir: "test",
            template: "javascript",
            type: "checkout_ui_extension",
            command: "serve",
            context: context,
          ).call
        end
      end

      def test_server_config_is_loaded_if_config_file_exists
        File.stubs(:exist?)
        File.stubs(:exist?).returns(true)
        server_config = Models::ServerConfig::Root.new(extensions: [extension])
        Tasks::MergeServerConfig.expects(:call).returns(server_config)

        dev_server = Models::DevelopmentServer.new(executable: "fake")
        Models::DevelopmentServer.expects(:new).returns(dev_server) do |server|
          server.expects(:build).with(server_config).returns(true)
        end

        CLI::Kit::System.expects(:capture3)
          .with(dev_server.executable, "build", "-", stdin_data: server_config.to_yaml)
          .returns(["", nil, mock(success?: true)])

        Tasks::RunExtensionCommand.new(
          root_dir: "test",
          template: "javascript",
          type: "checkout_ui_extension",
          command: "build",
          config_file_name: "test",
          context: context,
        ).call
      end

      private

      def extension
        renderer = Models::ServerConfig::DevelopmentRenderer.new(name: "@shopify/checkout-ui-extensions")
        entries = Models::ServerConfig::DevelopmentEntries.new(main: "src/index.js")
        development = Models::ServerConfig::Development.new(
          build_dir: "test",
          root_dir: "test",
          template: "javascript",
          renderer: renderer,
          entries: entries,
        )

        @extension ||= Models::ServerConfig::Extension.new(
          type: "checkout_ui_extension",
          uuid: "00000000-0000-0000-0000-000000000000",
          user: Models::ServerConfig::User.new,
          development: development
        )
      end

      def context
        TestHelpers::FakeContext.new
      end
    end
  end
end
