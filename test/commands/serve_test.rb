require 'test_helper'

module ShopifyCli
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::Context

      class FakeAppType < ShopifyCli::AppTypes::AppType
        def self.description; end

        def self.serve_command
          "a command"
        end
      end

      def setup
        super
        @command = ShopifyCli::Commands::Serve.new(@context)
        ShopifyCli::AppTypeRegistry.register(:fake, FakeAppType)
        content = <<~CONTENT
          ---
          app_type: :fake
        CONTENT
        File.write(File.join(@context.root, '.shopify-cli.yml'), content)
      end

      def teardown
        ShopifyCli::AppTypeRegistry.deregister(:fake)
        super
      end

      def test_run
        @context.expects(:exec).with('a command')
        @command.call([], nil)
      end
    end
  end
end
