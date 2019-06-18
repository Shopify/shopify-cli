require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class BillingTest < MiniTest::Test
        include TestHelpers::Context

        def setup
          super
          @command = ShopifyCli::Commands::Generate.new(@context)
        end

        def test_recurring_billing
          ShopifyCli::Project.write(@context, :node)
          CLI::UI::Prompt.expects(:ask).returns(:billing_recurring)
          @context.expects(:system).with('npm run-script generate-recurring-billing --silent')
            .returns(mock(success?: true))
          @command.call(['billing'], nil)
        end

        def test_one_time_billing
          ShopifyCli::Project.write(@context, :node)
          CLI::UI::Prompt.expects(:ask).returns(:billing_one_time)
          @context.expects(:system).with('npm run-script generate-one-time-billing --silent')
            .returns(mock(success?: true))
          @command.call(['billing'], nil)
        end
      end
    end
  end
end
