require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class BillingTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super()
          @cmd = ShopifyCli::Commands::Generate
          @cmd.ctx = @context
        end

        def test_recurring_billing
          CLI::UI::Prompt.expects(:ask).returns(:billing_recurring)
          @context.expects(:system).with('generate-recurring-billing')
            .returns(mock(success?: true))
          @cmd.call(['billing'], 'generate')
        end

        def test_one_time_billing
          CLI::UI::Prompt.expects(:ask).returns(:billing_one_time)
          @context.expects(:system).with('generate-one-time-billing')
            .returns(mock(success?: true))
          @cmd.call(['billing'], 'generate')
        end
      end
    end
  end
end
