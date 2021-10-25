# frozen_string_literal: true
require "yaml"

module Extension
  module Tasks
    module Converters
      class ServerConfigConverterTest < MiniTest::Test
        def test_server_config_converter_parses_extension_config_yaml
          type = "CHECKOUT_UI_EXTENSION"
          registration_uuid = "00000000-0000-0000-0000-000000000000"
          config_file = YAML.load(mock_extension_config_yaml)

          result = Converters::ServerConfigConverter.from_hash(
            hash: config_file,
            type: type,
            registration_uuid: registration_uuid
          )
          extension = result.extensions.first
          assert_equal(39351, result.port)
          assert_equal(type, extension.type)
          assert_equal(registration_uuid, extension.uuid)
          assert_equal("build", extension.development.build_dir)
          assert_equal("src/index.js", extension.development.entries.main)
          assert_equal(["Checkout::Feature::Render"], extension.extension_points)
          assert_equal("@shopify/checkout-ui-extensions", extension.development.renderer.name)
        end

        private

        def mock_extension_config_yaml
          <<~YAML
            ---
            development:
              entries:
                main: "src/index.js"
              build_dir: "build"
            extension_points:
              - Checkout::Feature::Render
          YAML
        end
      end
    end
  end
end
