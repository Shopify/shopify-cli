require 'test_helper'

module ShopifyCli
  module AppTypes
    class NodeTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @app = ShopifyCli::AppTypes::Node.new(name: 'test-app', ctx: @context)
      end

      def test_embedded_app_creation
        ShopifyCli::Tasks::JsDeps.stubs(:call).with(
          File.join(@context.root, 'test-app')
        )
        CLI::UI.expects(:ask).twice.returns('apikey', 'apisecret')
        @context.app_metadata[:host] = 'host'
        @context.expects(:write).with('.env',
          <<~KEYS
            SHOPIFY_API_KEY=apikey
            SHOPIFY_API_SECRET_KEY=apisecret
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
          CLI::UI.fmt('Run {{command:npm run dev}} to start the app server'),
          output
        )
      end
    end
  end
end
