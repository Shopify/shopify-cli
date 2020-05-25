# frozen_string_literal: true
require 'project_types/node/test_helper'

module Node
  module Commands
    module GenerateTests
      class BillingTest < MiniTest::Test
        include TestHelpers::FakeUI

        def test_recurring_billing
          CLI::UI::Prompt.expects(:ask).returns('recurring-billing')
          @context.expects(:system).with('recurring-billing')
            .returns(mock(success?: true))
          Node::Commands::Generate::Billing.new(@context).call([], '')
        end

        def test_one_time_billing
          CLI::UI::Prompt.expects(:ask).returns('one-time-billing')
          @context.expects(:system).with('one-time-billing')
            .returns(mock(success?: true))
          Node::Commands::Generate::Billing.new(@context).call([], '')
        end
      end
    end
  end
end
