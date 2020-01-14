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

        assert_match(/foobar.*was not found/, io.join)
      end

      def test_calls_help_with_h_flag
        no_project_context
        io = capture_io do
          run_cmd('create -h')
        end

        assert_match(CLI::UI.fmt(Create.help), io.join)
      end

      def test_calls_help_with_subcommand_h_flag
        no_project_context
        io = capture_io do
          run_cmd('create project -h')
        end

        assert_match(CLI::UI.fmt(Create::Project.help), io.join)
      end
    end
  end
end
