require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class BillingTest < MiniTest::Test
        include TestHelpers::Project
        include TestHelpers::FakeUI

        def setup
          super
          @command = ShopifyCli::Commands::Generate::Billing.new(@context)
        end

        def test_recurring_billing
          CLI::UI::Prompt.expects(:ask).returns(:billing_recurring)
          @context.expects(:system).with('generate-recurring-billing')
            .returns(mock(success?: true))
          @command.call(['billing'], nil)
        end

        def test_one_time_billing
          CLI::UI::Prompt.expects(:ask).returns(:billing_one_time)
          @context.expects(:system).with('generate-one-time-billing')
            .returns(mock(success?: true))
          @command.call(['billing'], nil)
        end
      end
    end
  end
end
