require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class PageTest < MiniTest::Test
        include TestHelpers::Project
        include TestHelpers::FakeUI

        def test_with_selection
          CLI::UI::Prompt.expects(:ask).returns(:empty_state)
          @context.expects(:system).with('generate-app empty-state-page name')
            .returns(mock(success?: true))
          run_cmd('generate page name')
        end

        def test_with_type_argument
          CLI::UI::Prompt.expects(:ask).never
          @context.expects(:system).with('generate-app list-page name')
            .returns(mock(success?: true))
          run_cmd('generate page name --type=list')
        end

        def test_raises_with_invalid_type
          assert_raises ShopifyCli::Abort do
            run_cmd('generate page name --type=list_TYPE test-app')
          end
        end

        def test_no_name_calls_help
          io = capture_io do
            run_cmd('generate page')
          end

          assert_match(CLI::UI.fmt(ShopifyCli::Commands::Generate::Page.help), io.join)
        end
      end
    end
  end
end
