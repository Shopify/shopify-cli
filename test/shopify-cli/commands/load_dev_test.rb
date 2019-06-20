require 'test_helper'

module ShopifyCli
  module Commands
    class LoadDevTest < MiniTest::Test
      def setup
        @command = ShopifyCli::Commands::LoadDev.new
      end

      def test_without_argument_uses_current_dir
        ShopifyCli::Finalize.expects(:reload_shopify_from).with(Dir.pwd)
        capture_io do
          @command.call([], nil)
        end
      end

      def test_with_argument
        dir = File.expand_path(Dir.pwd)
        ShopifyCli::Finalize.expects(:reload_shopify_from).with(dir)
        capture_io do
          @command.call([dir], nil)
        end
      end

      def test_with_missing_dir
        dir = File.join(Dir.mktmpdir, 'doesnotexist')
        assert_raises ShopifyCli::AbortSilent do
          capture_io do
            @command.call([dir], nil)
          end
        end
      end
    end
  end
end
