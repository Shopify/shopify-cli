# frozen_string_literal: true
require "test_helper"

module Extension
  module Tasks
    module ExecuteCommands
      class CreateTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_error_is_raised_if_error_occurs
          development_server = Models::DevelopmentServer.new(executable: "fake")
          Models::DevelopmentServer.expects(:new).returns(development_server) do |server|
            server.expects(:create).returns(StandardError)
          end

          assert_raises StandardError do
            ExecuteCommands::Create.new(
              type: "checkout_ui_extension",
              template: "javascript",
              root_dir: "test"
            ).call
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
end
