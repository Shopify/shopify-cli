# frozen_string_literal: true
require 'project_types/node/test_helper'

module Node
  module Commands
    module GenerateTests
      class WebhookTest < MiniTest::Test
        include TestHelpers::FakeUI
        include TestHelpers::Schema

        def test_with_existing_param
          @context.expects(:system).with('./node_modules/.bin/generate-node-app webhook APP_UNINSTALLED')
            .returns(mock(success?: true))
          run_cmd('generate webhook APP_UNINSTALLED')
        end

        def test_with_incorrect_param_expects_ask
          CLI::UI::Prompt.expects(:ask).returns('APP_UNINSTALLED')
          @context.expects(:system).with('./node_modules/.bin/generate-node-app webhook APP_UNINSTALLED')
            .returns(mock(success?: true))
          run_cmd('generate webhook create_webhook_fake')
        end

        def test_with_selection
          CLI::UI::Prompt.expects(:ask).returns('PRODUCT_CREATE')
          @context.expects(:system).with('./node_modules/.bin/generate-node-app webhook PRODUCT_CREATE')
            .returns(mock(success?: true))
          run_cmd('generate webhook')
        end
      end
    end
  end
end
