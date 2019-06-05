require 'test_helper'

module ShopifyCli
  module AppTypes
    class NodeTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @app = ShopifyCli::AppTypes::Node.new(name: 'test-app', ctx: @context)
        @context.app_metadata[:host] = 'host'
        @context.app_metadata[:api_key] = 'api_key'
        @context.app_metadata[:secret] = 'secret'
      end

      def test_build_creates_app
        ShopifyCli::Tasks::Clone.stubs(:call).with(
          'git@github.com:shopify/webgen-embeddedapp.git',
          'test-app',
        )
        ShopifyCli::Tasks::JsDeps.stubs(:call).with(@context.root)
        @context.expects(:write).with('.env',
          <<~KEYS
            SHOPIFY_API_KEY=api_key
            SHOPIFY_API_SECRET_KEY=secret
            HOST=host
            SCOPES=read_products
          KEYS
        )
        @context.expects(:rm_r).with(File.join(@context.root, '.git'))
        @context.expects(:rm_r).with(File.join(@context.root, '.github'))
        io = capture_io do
          @app.build
        end
        output = io.join

        assert_match(
          CLI::UI.fmt('Run {{command:shopify serve}} to start the app server'),
          output
        )
      end

      def test_build_does_not_error_on_missing_git_dir
        ShopifyCli::Tasks::Clone.stubs(:call).with(
          'git@github.com:shopify/webgen-embeddedapp.git',
          'test-app',
        )
        ShopifyCli::Tasks::JsDeps.stubs(:call).with(@context.root)
        @context.expects(:write)
        @app.build
      end

      def test_server_command
        ShopifyCli::Project.expects(:current).returns(
          TestHelpers::FakeProject.new(
            directory: @context.root,
            config: {
              'app_type' => 'node',
            }
          )
        )
        @context.app_metadata[:host] = 'https://example.com'
        cmd = ShopifyCli::Commands::Serve.new(@context)
        @context.expects(:system).with(
          "HOST=https://example.com PORT=8081 npm run dev"
        )
        cmd.call([], nil)
      end
    end
  end
end
