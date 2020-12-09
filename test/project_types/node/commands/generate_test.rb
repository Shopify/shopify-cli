# frozen_string_literal: true
require 'project_types/node/test_helper'

module Node
  module Commands
    class GenerateTest < MiniTest::Test
      def test_without_arguments_calls_help
        @context.expects(:puts).with(Node::Commands::Generate.help)
        Node::Commands::Generate.new(@context).call
      end

      def test_run_generate_raises_abort_when_not_successful
        m = mock
        m.stubs(:success?).returns(false)
        m.stubs(:exitstatus).returns(1)
        @context.expects(:system).with(%w[npm run-dev run-script generate-page --silent]).returns(m)

        assert_raises(ShopifyCli::Abort) do
          Node::Commands::Generate.run_generate(%w[npm run-dev run-script generate-page --silent], 'test', @context)
        end
      end
    end
  end
end
