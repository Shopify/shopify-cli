# frozen_string_literal: true
require 'project_types/node/test_helper'

module Node
  module Commands
    module GenerateTests
      class PageTest < MiniTest::Test
        include TestHelpers::Project
        include TestHelpers::FakeUI

        BIN_REGEX = 'node_modules\/\.bin\/generate-node-app'

        def test_with_selection
          CLI::UI::Prompt.expects(:ask).returns(Node::Commands::Generate::Page::PAGE_TYPES['empty-state'])
          @context
            .expects(:system)
            .with(regexp_matches(Regexp.new("^.*#{BIN_REGEX}\\\" empty-state-page name$")))
            .returns(mock(success?: true))
          Node::Commands::Generate::Page.new(@context).call(['name'], '')
        end

        def test_with_type_argument
          CLI::UI::Prompt.expects(:ask).never
          @context
            .expects(:system)
            .with(regexp_matches(Regexp.new("^.*#{BIN_REGEX}\\\" list-page name$")))
            .returns(mock(success?: true))
          command = Node::Commands::Generate::Page.new(@context)
          command.options.flags[:type] = 'list'
          command.call(['name'], '')
        end

        def test_raises_with_invalid_type
          assert_raises ShopifyCli::Abort do
            command = Node::Commands::Generate::Page.new(@context)
            command.options.flags[:type] = 'list_TYPE'
            command.call(['name'], '')
          end
        end

        def test_no_name_calls_help
          @context.expects(:puts).with(Node::Commands::Generate::Page.help)
          Node::Commands::Generate::Page.new(@context).call([], '')
        end
      end
    end
  end
end
