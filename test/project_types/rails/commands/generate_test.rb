# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class GenerateTest < MiniTest::Test
      def test_without_arguments_calls_help
        @context.expects(:puts).with(Rails::Command::Generate.help)
        Rails::Command::Generate.new(@context).call
      end

      def test_run_generate_raises_abort_when_not_successful
        failure = mock
        failure.stubs(:success?).returns(false)
        failure.stubs(:exitstatus).returns(1)
        ShopifyCli::Context.any_instance.expects(:system).returns(failure)

        assert_raises(ShopifyCli::Abort) do
          Rails::Command::Generate.run_generate(["script"], "test-name", @context)
        end
      end
    end
  end
end
