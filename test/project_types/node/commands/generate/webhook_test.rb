# frozen_string_literal: true
require 'project_types/node/test_helper'

module Node
  module Commands
    module GenerateTests
      class WebhookTest < MiniTest::Test
        include TestHelpers::FakeUI
        include TestHelpers::Schema

        BIN_REGEX = 'node_modules\/\.bin\/generate-node-app'

        def test_with_existing_param
          @context.expects(:system).with(regexp_matches(Regexp.new("^.*#{BIN_REGEX}\\\" webhook APP_UNINSTALLED$")))
            .returns(mock(success?: true))
          Node::Commands::Generate::Webhook.new(@context).call(['APP_UNINSTALLED'], '')
        end

        def test_with_incorrect_param_expects_ask
          CLI::UI::Prompt.expects(:ask).returns('APP_UNINSTALLED')
          @context.expects(:system).with(regexp_matches(Regexp.new("^.*#{BIN_REGEX}\\\" webhook APP_UNINSTALLED$")))
            .returns(mock(success?: true))
          Node::Commands::Generate::Webhook.new(@context).call(['create_webhook_fake'], '')
        end

        def test_with_selection
          CLI::UI::Prompt.expects(:ask).returns('PRODUCT_CREATE')
          @context.expects(:system).with(regexp_matches(Regexp.new("^.*#{BIN_REGEX}\\\" webhook PRODUCT_CREATE$")))
            .returns(mock(success?: true))
          Node::Commands::Generate::Webhook.new(@context).call([], '')
        end
      end
    end
  end
end
