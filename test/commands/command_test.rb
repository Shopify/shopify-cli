require 'test_helper'

module ShopifyCli
  module Commands
    class CommandTest < MiniTest::Test
      def setup
        @command = ShopifyCli::Commands::Help.new
      end

      def test_non_existant
        io = capture_io do
          @command.call(%w(foobar), nil)
        end

        assert_match(/Available commands/, io.join)
      end
    end
  end
end
