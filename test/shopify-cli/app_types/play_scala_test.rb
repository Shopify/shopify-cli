require 'test_helper'

module ShopifyCli
  module AppTypes
    class PlayScalaBuildTest < MiniTest::Test
      def setup
        @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
        @app = ShopifyCli::AppTypes::PlayScala.new(ctx: @context)
        @context.app_metadata = {
          host: 'host',
          api_key: 'api_key',
          secret: 'secret',
        }
      end

      def test_build_creates_app
        ShopifyCli::Tasks::Clone.stubs(:call).with('git@github.com:fulrich/scalify-play-example.git', 'test-app')
        @context.expects(:write).with('.env',
          <<~KEYS
            SHOPIFY_API_KEY=api_key
            SHOPIFY_API_SECRET_KEY=secret
            HOST=host
            SCOPES=write_products,write_customers,write_draft_orders
          KEYS
        )
        @context.expects(:rm_r).with(File.join(@context.root, '.git'))
        @context.expects(:rm_r).with(File.join(@context.root, '.github'))

        io = capture_io do
          @app.build('test-app')
        end
        output = io.join

        assert_match(
          CLI::UI.fmt('Run {{command:shopify serve}} to start the local development server'),
          output
        )
      end

      def test_check_dependencies_command
        @context.expects(:capture2e).with(
          'sbt sbtVersion'
        ).returns(['1.2.3', mock(success?: true)])
        @context.expects(:capture2e).with(
          'javac -version'
        ).returns(['javac 1.8', mock(success?: true)])

        io = capture_io do
          @app.check_dependencies
        end
        output = io.join
        assert_match('SBT 1.2.3', output)
        assert_match('javac 1.8', output)
      end
    end

    class PlayScalaTest < MiniTest::Test
      include TestHelpers::Project

      def setup
        project_context('app_types', 'play_scala')
        @app = ShopifyCli::AppTypes::PlayScala.new(ctx: @context)
        Helpers::EnvFile.any_instance.stubs(:write)
      end

      def test_server_command
        cmd = ShopifyCli::Commands::Serve.new(@context)
        @context.expects(:system).with(
          "sbt -Dplay.filters.hosts.allowed.0=example.com -Dshopify.apiKey=mykey -Dshopify.apiSecret=mysecretkey \"run 8081\""
        )
        cmd.call([], nil)
      end

      def test_open_command
        cmd = ShopifyCli::Commands::Open.new(@context)
        @context.expects(:system).with(
          'open',
          'https://example.com/unsafe_install?shop=my-test-shop.myshopify.com'
        )
        cmd.call([], nil)
      end
    end
  end
end
