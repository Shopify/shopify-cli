# typed: ignore
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

        def teardown
          FileUtils.rm_rf("tmp")
        end

        def test_success_object_is_returned_on_successful_call
          Dir.mkdir("tmp") unless Dir.exist?("tmp")
          FileUtils.touch("tmp/test.txt")

          test_file_path = File.join(Dir.pwd, "tmp")

          result = ExecuteCommands::Serve.new(
            type: "checkout_ui_extension",
            config_file_path: File.join(test_file_path, "test.txt"),
            context: TestHelpers::FakeContext.new,
            tunnel_url: "http://example.ngrok.io"
          ).call
          assert_kind_of(ShopifyCLI::Result::Success, result)
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
