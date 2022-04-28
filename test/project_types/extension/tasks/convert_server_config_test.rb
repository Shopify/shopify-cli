# frozen_string_literal: true
require "test_helper"
require "yaml"

module Extension
  module Tasks
    class ConvertServerConfigTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
        @api_key = "123abc"
        @build = "build"
        @config_file = YAML.load(mock_extension_config_yaml)
        @entry_main = "src/index.js"
        @extension_points = ["Checkout::Feature::Render"]
        @network_access = true
        @fake_context = TestHelpers::FakeContext.new
        @registration_uuid = "00000000-0000-0000-0000-000000000000"
        @store = "my-test-store"
        @title = "Extension title"
        @tunnel_url = "https://shopify.ngrok.io"
        @type = "CHECKOUT_UI_EXTENSION"
        stub_renderer_package
      end

      def test_server_config_converter_parses_extension_config_yaml
        result = Tasks::ConvertServerConfig.call(
          api_key: @api_key,
          context: @fake_context,
          hash: @config_file,
          registration_uuid: @registration_uuid,
          store: @store,
          title: @title,
          tunnel_url: @tunnel_url,
          type: @type,
          port: 1234
        )

        extension = result.extensions.first

        expected = mock_extension_config

        assert_equal(expected.to_hash, extension.to_hash)
      end

      def test_server_config_converter_sets_default_build_directory
        @config_file["development"].delete("build_dir")

        result = Tasks::ConvertServerConfig.call(
          api_key: @api_key,
          context: @fake_context,
          hash: @config_file,
          registration_uuid: @registration_uuid,
          store: @store,
          title: @title,
          tunnel_url: @tunnel_url,
          type: @type,
          port: 1234
        )

        extension = result.extensions.first
        assert_equal("build", extension.to_hash.dig("development", "build_dir"))
      end

      def test_resource_url_included_if_one_given
        resource_url = "/cart/1:1"
        result = Tasks::ConvertServerConfig.call(
          api_key: @api_key,
          context: @fake_context,
          hash: @config_file,
          registration_uuid: @registration_uuid,
          resource_url: resource_url,
          store: @store,
          title: @title,
          tunnel_url: @tunnel_url,
          type: @type,
          port: 1234
        )

        assert_equal(resource_url, result.extensions.first.development.resource.url)
      end

      def test_empty_config_and_entry_fallback
        project_directory = Pathname(ExtensionProject.current.directory)
        FileUtils.mkdir_p(project_directory.join("src"))
        File.write(project_directory.join("src/index.js"), "")

        assert_nothing_raised do
          result = Tasks::ConvertServerConfig.call(
            api_key: @api_key,
            context: @fake_context,
            hash: {},
            registration_uuid: @registration_uuid,
            store: @store,
            title: @title,
            tunnel_url: @tunnel_url,
            type: @type,
            port: 1234
          )

          refute(result.extensions.first.capabilities.network_access)
        end
      ensure
        FileUtils.rm_r(project_directory.join("src/"))
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
          capabilities:
            network_access: true
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
          capabilities: Models::ServerConfig::Capabilities.new(
            network_access: @network_access
          ),
          version: @version,
          title: @title
        )
      end
    end
  end
end
