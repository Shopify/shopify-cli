require 'test_helper'

module ShopifyCli
  module AppTypes
    class NodeTest < MiniTest::Test
      def setup
        @app = ShopifyCli::AppTypes::Node.new
      end

      def test_embedded_app_creation
        ShopifyCli::Tasks::Clone.stubs(:call).with(
          'git@github.com:shopify/webgen-embeddedapp.git',
          'test-app'
        )
        CLI::UI.expects(:ask).twice.returns('apikey', 'apisecret')
        @app.expects(:write_env_file)
        @app.expects(:yarn)
        io = capture_io do
          @app.call('test-app')
        end
        output = io.join

        assert_match('Installing dependencies...', output)
      end
    end
  end
end
