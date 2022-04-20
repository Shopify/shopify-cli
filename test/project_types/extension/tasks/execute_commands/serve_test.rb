# frozen_string_literal: true
require "test_helper"

module Extension
  module Tasks
    module ExecuteCommands
      class ServeTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
          server_config = Models::ServerConfig::Root.new(extensions: [extension])
          Tasks::MergeServerConfig.expects(:call).returns(server_config)
          CLI::Kit::System.stubs(:popen3).returns("fake output")
        end

        def test_success_object_is_returned_on_successful_call
          FileUtils.touch("extension.config.yml")
          File.write("package.json", JSON.dump(up_to_date_package_json))

          result = ExecuteCommands::Serve.new(
            type: "checkout_ui_extension",
            config_file_path: "extension.config.yml",
            context: TestHelpers::FakeContext.new,
            tunnel_url: "http://example.ngrok.io"
          ).call

          assert_kind_of(ShopifyCLI::Result::Success, result)
        ensure
          FileUtils.rm("extension.config.yml")
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

        def up_to_date_package_json
          {
            "name": "test-extension",
            "dependencies": {
              "@shopify/checkout-ui-extensions": "^1.0.0",
            },
            "devDependencies": {
              "@shopify/shopify-cli-extensions": "latest",
            },
            "scripts": {
              "build": "some command",
              "develop": "some command",
            },
          }
        end
      end
    end
  end
end
