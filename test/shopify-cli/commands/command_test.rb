require 'test_helper'

module ShopifyCli
  module Commands
    class CommandTest < MiniTest::Test
      def test_non_existant
        io = capture_io do
          assert_raises(ShopifyCli::AbortSilent) do
            run_cmd('foobar')
          end
        end

        assert_match(/Available commands/, io.join)
      end
    end
  end
end
