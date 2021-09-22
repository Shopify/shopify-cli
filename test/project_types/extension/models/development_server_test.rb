require "test_helper"

module Extension
  module Models
    class DevelopmentServerTest < MiniTest::Test
      def setup
        ShopifyCLI::ProjectType.load_type(:extension)
        super
      end

      def test_default_executable_is_shopify_extensions
        development_server = Models::DevelopmentServer.new
        assert_includes(development_server.executable, "ext/shopify-cli/shopify-extensions")
      end

      def test_create_calls_executable_and_is_successful
        assert_nothing_raised do
          development_server = Models::DevelopmentServer.new(executable: "fake")
          server_config = Models::ServerConfig::Root.new(extensions: [extension])

          CLI::Kit::System.expects(:capture3)
            .with(development_server.executable, "create", "-", stdin_data: server_config.to_yaml)
            .returns("", nil, true)

          development_server.create(server_config)
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
