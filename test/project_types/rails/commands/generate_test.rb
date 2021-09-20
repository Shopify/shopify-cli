# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class GenerateTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Rails::Command::Generate.help)
        run_generate
      end

      def test_run_generate_raises_abort_when_not_successful
        failure = mock
        failure.stubs(:success?).returns(false)
        failure.stubs(:exitstatus).returns(1)
        ShopifyCLI::Context.any_instance.expects(:system).returns(failure)

        assert_raises(ShopifyCLI::Abort) do
          Rails::Command::Generate.run_generate(["script"], "test-name", @context)
        end
      end

      def test_with_webhook_argument_calls_webhook
        Rails::Command::Generate::Webhook.expects(:start)
        run_generate("webhook")
      end

      private

      def run_generate(*args)
        run_cmd("rails generate " + args.join(" "))
      end
    end
  end
end
