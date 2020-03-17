require 'test_helper'

module Node
  module Commands
    class Generate
      class BillingTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          ShopifyCli::ProjectType.load_type(:node)
        end

        def test_recurring_billing
          CLI::UI::Prompt.expects(:ask).returns('recurring-billing')
          @context.expects(:system).with('./node_modules/.bin/generate-node-app recurring-billing')
            .returns(mock(success?: true))
          run_cmd('generate billing')
        end

        def test_one_time_billing
          CLI::UI::Prompt.expects(:ask).returns('one-time-billing')
          @context.expects(:system).with('./node_modules/.bin/generate-node-app one-time-billing')
            .returns(mock(success?: true))
          run_cmd('generate billing')
        end
      end
    end
  end
end