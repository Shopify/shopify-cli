# frozen_string_literal: true
require "project_types/node/test_helper"

module ShopifyCLI
  module Commands
    class PopulateTest < MiniTest::Test
      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCLI::Commands::Populate.help)
        run_cmd("populate")
      end

      def test_with_invalid_subcommand
        io = capture_io do
          run_cmd("populate foobar")
        end

        assert_match(CLI::UI.fmt(ShopifyCLI::Commands::Populate.help), io.join)
      end
    end
  end
end
