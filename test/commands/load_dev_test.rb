require 'test_helper'

module ShopifyCli
  module Commands
    class LoadDevTest < MiniTest::Test
      def setup
        @command = ShopifyCli::Commands::LoadDev.new
      end

      def test_without_argument_uses_current_dir
        ShopifyCli::Finalize.expects(:reload_shopify_from).with(Dir.pwd)
        io = capture_io do
          @command.call([], nil)
        end
      end

      def test_with_argument
        ShopifyCli::Finalize.expects(:reload_shopify_from).with(
          File.expand_path('~/shopify-cli')
        )
        io = capture_io do
          @command.call(['~/shopify-cli'], nil)
        end
      end
    end
  end
end
