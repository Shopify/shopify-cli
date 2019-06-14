require 'test_helper'

module ShopifyCli
  module AppTypes
    class NodeTest < MiniTest::Test
      include TestHelpers::Context
      include TestHelpers::Constants

      def setup
        super
        @app = ShopifyCli::AppTypes::Node.new(ctx: @context)
        @context.app_metadata = {
          host: 'host',
          api_key: 'api_key',
          secret: 'secret',
        }
      end

      def test_build_creates_app
        ShopifyCli::Tasks::Clone.stubs(:call).with(
          'git@github.com:shopify/shopify-app-node.git',
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
          @app.build('test-app')
        end
        output = io.join

        assert_match(
          CLI::UI.fmt('Run {{command:shopify serve}} to start the app server'),
          output
        )
      end

      def test_check_dependencies_command
        @context.expects(:capture2e).with(
          'node -v'
        ).returns(['8.0.0', mock(success?: true)])

        io = capture_io do
          @app.check_dependencies
        end
        output = io.join
        assert_match('8.0.0', output)
      end

      def test_check_dependencies_command_error
        assert_raises ShopifyCli::Abort do
          @context.expects(:capture2e).with(
            'node -v'
          ).returns([nil, mock(success?: false)])
          capture_io do
            @app.check_dependencies
          end
        end
      end

      def test_build_does_not_error_on_missing_git_dir
        ShopifyCli::Tasks::Clone.stubs(:call).with(
          'git@github.com:shopify/shopify-app-node.git',
          'test-app',
        )
        ShopifyCli::Tasks::JsDeps.stubs(:call).with(@context.root)
        @context.expects(:write)
        @app.build('test-app')
      end

      def test_server_command
        @context.stubs(:project).returns(
          Project.at(File.join(FIXTURE_DIR, 'app_types/node'))
        ).at_least_once
        @context.app_metadata[:host] = 'https://example.com'
        cmd = ShopifyCli::Commands::Serve.new(@context)
        @context.expects(:system).with(
          "HOST=https://example.com PORT=8081 npm run dev"
        )
        cmd.call([], nil)
      end

      def test_open_command
        @context.stubs(:project).returns(
          Project.at(File.join(FIXTURE_DIR, 'app_types/node'))
        ).at_least_once
        cmd = ShopifyCli::Commands::Open.new(@context)
        @context.expects(:system).with(
          'open',
          'https://example.com/auth?shop=my-test-shop.myshopify.com'
        )
        cmd.call([], nil)
      end
    end
  end
end
