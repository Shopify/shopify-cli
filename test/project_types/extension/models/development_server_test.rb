require "test_helper"

module Extension
  module Models
    class DevelopmentServerTest < MiniTest::Test
      def setup
        ShopifyCLI::ProjectType.load_type(:extension)
        @development_server = Models::DevelopmentServer.new(executable: "fake")
        super
      end

      def test_default_executable_is_shopify_extensions
        development_server = Models::DevelopmentServer.new
        assert_includes(development_server.executable, "ext/shopify-extensions")
      end

      def test_create_calls_executable_and_is_successful
        assert_nothing_raised do
          server_config = Models::ServerConfig::Root.new(extensions: [extension])

          CLI::Kit::System.expects(:capture3)
            .with(@development_server.executable, "create", "-", stdin_data: server_config.to_yaml)
            .returns("", nil, true)

          @development_server.create(server_config)
        end
      end

      def test_build_calls_executable_and_is_successful
        assert_nothing_raised do
          server_config = Models::ServerConfig::Root.new(extensions: [extension])

          CLI::Kit::System.expects(:capture3)
            .with(@development_server.executable, "build", "-", stdin_data: server_config.to_yaml)
            .returns(["", nil, mock(success?: true)])

          @development_server.build(server_config)
        end
      end

      def test_build_raises_error_on_failure
        error_message = "an error from stdout"

        expected_error = assert_raises Models::DevelopmentServer::DevelopmentServerError do
          server_config = Models::ServerConfig::Root.new(extensions: [extension])

          CLI::Kit::System.expects(:capture3)
            .with(@development_server.executable, "build", "-", stdin_data: server_config.to_yaml)
            .returns(["", error_message, mock(success?: false)])

          @development_server.build(server_config)
        end
        assert_equal(expected_error.message, error_message)
      end

      def test_serve_runs_successfully
        assert_nothing_raised do
          server_config = Models::ServerConfig::Root.new(extensions: [extension])
          development_server = Models::DevelopmentServer.new(executable: "fake")

          CLI::Kit::System.stubs(:popen3).with(development_server.executable, "serve", "-").returns(nil)
          development_server.serve(@ctx, server_config)
        end
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
    end
  end
end
