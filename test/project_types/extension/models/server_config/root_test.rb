# frozen_string_literal: true
require "test_helper"

module Extension
  module Models
    module ServerConfig
      class RootTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_root_is_created_with_valid_attributes
          assert_nothing_raised do
            Models::ServerConfig::Root.new(
              extensions: [extension]
            )
          end
        end

        def test_server_config_root_yaml_output
          config_file = Models::ServerConfig::Root.new(extensions: [extension])

          refute_includes(config_file.to_yaml, "---\n")
          refute_includes(config_file.to_yaml, "!ruby/")
          refute_match(/:.+:/, config_file.to_yaml)
        end

        private

        def extension
          renderer = ServerConfig::DevelopmentRenderer.new(name: "@shopify/checkout-ui-extensions")
          entries = ServerConfig::DevelopmentEntries.new(main: "src/index.js")
          development = ServerConfig::Development.new(
            build_dir: "test",
            root_dir: "test",
            template: "javascript",
            renderer: renderer,
            entries: entries,
          )

          ServerConfig::Extension.new(
            type: "checkout-ui-extension",
            uuid: "00000000-0000-0000-0000-000000000000",
            user: ServerConfig::User.new,
            development: development
          )
        end
      end
    end
  end
end
