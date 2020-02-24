require 'test_helper'

module ShopifyCli
  class ContextualResolverTest < MiniTest::Test
    def test_outputs_help_with_help_flag
      ShopifyCli::Commands::Help.expects(:call)
      assert_raises(ShopifyCli::AbortSilent) do
        run_cmd('-h')
      end
    end

    def test_outputs_help_without_argument
      ShopifyCli::Commands::Help.expects(:call)
      run_cmd('')
    end

    def test_unavailable_command_at_top_level
      no_project_context
      output = capture_io do
        assert_raises(ShopifyCli::AbortSilent) do
          run_cmd('serve')
        end
      end.join

      assert_match('not available here', output)
    end
  end
end
