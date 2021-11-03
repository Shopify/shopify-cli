# frozen_string_literal: true
require "test_helper"
require "yaml"

module Extension
  module Tasks
    module Converters
      class ServerConfigConverterTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
          @config_file = YAML.load(mock_extension_config_yaml)
          @registration_uuid = "00000000-0000-0000-0000-000000000000"
          @store = "my-test-store"
          @tunnel_url = "https://shopify.ngrok.io"
          @type = "CHECKOUT_UI_EXTENSION"
        end

        def test_server_config_converter_parses_extension_config_yaml
          result = Converters::ServerConfigConverter.from_hash(
            hash: @config_file,
            type: @type,
            registration_uuid: @registration_uuid,
            store: @store,
            tunnel_url: @tunnel_url,
          )

          extension = result.extensions.first
          assert_equal(@store, result.store)
          assert_equal(@tunnel_url, result.public_url)
          assert_equal(@type, extension.type)
          assert_equal(@registration_uuid, extension.uuid)
          assert_equal("build", extension.development.build_dir)
          assert_equal("src/index.js", extension.development.entries.main)
          assert_equal(["Checkout::Feature::Render"], extension.extension_points)
          assert_equal("@shopify/checkout-ui-extensions", extension.development.renderer.name)
        end

        def test_resource_url_included_if_one_given
          resource_url = "/cart/1:1"
          result = Converters::ServerConfigConverter.from_hash(
            hash: @config_file,
            type: @type,
            registration_uuid: @registration_uuid,
            store: @store,
            tunnel_url: @tunnel_url,
            resource_url: resource_url,
          )

          assert_equal(resource_url, result.extensions.first.development.resource.url)
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
