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
          @api_key = "123abc"
          @build = "build"
          @config_file = YAML.load(mock_extension_config_yaml)
          @entry_main = "src/index.js"
          @extension_points = ["Checkout::Feature::Render"]
          @fake_context = "fake_context"
          @registration_uuid = "00000000-0000-0000-0000-000000000000"
          @store = "my-test-store"
          @tunnel_url = "https://shopify.ngrok.io"
          @type = "CHECKOUT_UI_EXTENSION"
          stub_renderer_package
        end

        def test_server_config_converter_parses_extension_config_yaml
          result = Converters::ServerConfigConverter.from_hash(
            api_key: @api_key,
            context: @fake_context,
            hash: @config_file,
            registration_uuid: @registration_uuid,
            store: @store,
            tunnel_url: @tunnel_url,
            type: @type
          )

          extension = result.extensions.first

          expected = mock_extension_config

          assert_equal(expected.to_hash, extension.to_hash)
        end

        def test_resource_url_included_if_one_given
          resource_url = "/cart/1:1"
          result = Converters::ServerConfigConverter.from_hash(
            api_key: @api_key,
            context: @fake_context,
            hash: @config_file,
            registration_uuid: @registration_uuid,
            resource_url: resource_url,
            store: @store,
            tunnel_url: @tunnel_url,
            type: @type
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

        def stub_renderer_package
          Tasks::FindPackageFromJson.expects(:call).returns(Models::NpmPackage.new(name: "test", version: @version))
        end

        def mock_extension_config
          Models::ServerConfig::Extension.new(
            uuid: @registration_uuid,
            type: @type.upcase,
            user: Models::ServerConfig::User.new,
            development: Models::ServerConfig::Development.new(
              build_dir: @build,
              renderer: Models::ServerConfig::DevelopmentRenderer.find(@type),
              entries: Models::ServerConfig::DevelopmentEntries.new(
                main: @entry_main
              )
            ),
            extension_points: @extension_points,
            version: @version
          )
        end
      end
    end
  end
end
