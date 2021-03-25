# frozen_string_literal: true
require "project_types/node/test_helper"

module ShopifyCli
  module Commands
    class PopulateTest < MiniTest::Test
      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Populate.help)
        run_cmd("populate")
      end

      def test_with_invalid_subcommand
        io = capture_io do
          run_cmd("populate foobar")
        end

        assert_match(CLI::UI.fmt(ShopifyCli::Commands::Populate.help), io.join)
      end
    end
  end
end
