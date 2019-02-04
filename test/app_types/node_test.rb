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
        ShopifyCli::Tasks::JsDeps.stubs(:call).with(
          File.join(Dir.pwd, 'test-app')
        )
        CLI::UI.expects(:ask).twice.returns('apikey', 'apisecret')
        @app.expects(:write_env_file)
        io = capture_io do
          @app.call('test-app')
        end
        output = io.join

        assert_match(
          CLI::UI.fmt('Run {{command:shopify server}} to start the app server'),
          output
        )
      end
    end
  end
end
