# frozen_string_literal: true
require 'project_types/node/test_helper'

module Node
  module Commands
    module GenerateTests
      class BillingTest < MiniTest::Test
        include TestHelpers::FakeUI

        BIN_REGEX = 'node_modules\/\.bin\/generate-node-app'

        def test_recurring_billing
          CLI::UI::Prompt.expects(:ask).returns(Node::Commands::Generate::Billing::BILLING_TYPES['recurring-billing'])
          @context
            .expects(:system)
            .with(regexp_matches(Regexp.new("^.*#{BIN_REGEX}\\\" recurring-billing$")))
            .returns(mock(success?: true))
          Node::Commands::Generate::Billing.new(@context).call([], '')
        end

        def test_one_time_billing
          CLI::UI::Prompt.expects(:ask).returns(Node::Commands::Generate::Billing::BILLING_TYPES['one-time-billing'])
          @context
            .expects(:system)
            .with(regexp_matches(Regexp.new("^.*#{BIN_REGEX}\\\" one-time-billing$")))
            .returns(mock(success?: true))
          Node::Commands::Generate::Billing.new(@context).call([], '')
        end
      end
    end
  end
end
