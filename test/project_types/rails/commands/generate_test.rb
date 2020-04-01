require 'test_helper'

module Rails
  module Commands
    class GenerateTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:rails)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Rails::Commands::Generate.help)
        run_cmd('generate')
      end

      def test_help_argument_calls_extended_help
        @context.expects(:puts).with(Rails::Commands::Generate.help + "\n" + Rails::Commands::Generate.extended_help)
        run_cmd('help generate')
      end

      def test_run_generate_raises_abort_when_not_successful
        failure = mock
        failure.stubs(:success?).returns(false)
        failure.stubs(:exitstatus).returns(1)
        ShopifyCli::Context.any_instance.expects(:system).returns(failure)

        assert_raises(ShopifyCli::Abort) do
          Rails::Commands::Generate.run_generate(['script'], 'test-name', @context)
        end
      end
    end
  end
end
