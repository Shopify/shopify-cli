require 'test_helper'

module Node
  module Commands
    class GenerateTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:node)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Node::Commands::Generate.help)
        run_cmd('generate')
      end

      def test_help_argument_calls_extended_help
        @context.expects(:puts).with(Node::Commands::Generate.help + "\n" + Node::Commands::Generate.extended_help)
        run_cmd('help generate')
      end

      def test_run_generate_raises_abort_when_not_successful
        m = mock
        m.stubs(:success?).returns(false)
        m.stubs(:exitstatus).returns(1)
        @context.expects(:system).with(
          [
            'npm',
            'run-dev',
            'run-script',
            'generate-page',
            '--silent',
          ]
        ).returns(m)

        assert_raises(ShopifyCli::Abort) do
          Node::Commands::Generate.run_generate(
            [
              'npm',
              'run-dev',
              'run-script',
              'generate-page',
              '--silent',
            ], 'test', @context
          )
        end
      end
    end
  end
end
