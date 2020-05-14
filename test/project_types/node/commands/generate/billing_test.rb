require 'test_helper'

module Node
  module Commands
    module GenerateTests
      class BillingTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          ShopifyCli::ProjectType.load_type(:node)
        end

        def test_recurring_billing
          CLI::UI::Prompt.expects(:ask).returns('recurring-billing')
          @context.expects(:system).with('recurring-billing')
            .returns(mock(success?: true))
          run_cmd('generate billing')
        end

        def test_one_time_billing
          CLI::UI::Prompt.expects(:ask).returns('one-time-billing')
          @context.expects(:system).with('one-time-billing')
            .returns(mock(success?: true))
          run_cmd('generate billing')
        end
      end
    end
  end
end
