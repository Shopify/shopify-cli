require 'test_helper'

module ShopifyCli
  module Commands
    class CommandTest < MiniTest::Test
      include TestHelpers::Context

      def test_non_existant
        command = ShopifyCli::Commands::Help.new(@context)
        io = capture_io do
          command.call(%w(foobar), nil)
        end

        assert_match(/Available commands/, io.join)
      end
    end
  end
end
