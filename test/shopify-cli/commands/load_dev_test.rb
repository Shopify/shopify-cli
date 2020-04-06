require 'test_helper'

module ShopifyCli
  module Commands
    class LoadDevTest < MiniTest::Test
      def test_without_argument_uses_current_dir
        ShopifyCli::Core::Finalize.expects(:reload_shopify_from).with(Dir.pwd)
        capture_io do
          run_cmd('load-dev')
        end
      end

      def test_with_argument
        dir = File.expand_path(Dir.pwd)
        ShopifyCli::Core::Finalize.expects(:reload_shopify_from).with(dir)
        capture_io do
          run_cmd("load-dev #{dir}")
        end
      end

      def test_with_missing_dir
        dir = File.join(Dir.mktmpdir, 'doesnotexist')
        assert_raises ShopifyCli::AbortSilent do
          capture_io do
            run_cmd("load-dev #{dir}")
          end
        end
      end
    end
  end
end
