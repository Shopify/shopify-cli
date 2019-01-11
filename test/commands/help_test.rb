require 'test_helper'

module ShopifyCli
  module Commands
    class HelpTest < MiniTest::Test
      def setup
        @command = ShopifyCli::Commands::Help.new
      end

      def test_default_behavior_lists_tasks
        io = capture_io do
          @command.call([], nil)
        end
        output = io.join

        assert_match('Available commands', output)
        assert_match(/Usage: .*shopify/, output)
      end
    end
  end
end
