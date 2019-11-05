require 'test_helper'

module ShopifyCli
  module Commands
    class FakeCommand < ShopifyCli::Command
      class << self
        def help
          "basic help"
        end

        def extended_help
          "extended help"
        end
      end
    end

    class HelpTest < MiniTest::Test
      def setup
        ShopifyCli::Commands.register(:FakeCommand, 'fake')
      end

      def test_default_behavior_lists_tasks
        io = capture_io do
          run_cmd('help')
        end
        output = io.join

        assert_match('Available commands', output)
        assert_match(/Usage: .*shopify/, output)
      end

      def test_extended_help_for_individual_command
        io = capture_io do
          run_cmd('help fake')
        end
        output = io.join
        assert_match(/basic help.*extended help/m, output)
      end
    end
  end
end
