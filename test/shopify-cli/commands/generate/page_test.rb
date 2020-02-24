require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class PageTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          project_context('app_types/node')
        end

        def test_with_selection
          CLI::UI::Prompt.expects(:ask).returns(:empty_state)
          @context.expects(:system).with('./node_modules/.bin/generate-node-app empty-state-page name')
            .returns(mock(success?: true))
          run_cmd('generate page name')
        end

        def test_with_type_argument
          CLI::UI::Prompt.expects(:ask).never
          @context.expects(:system).with('./node_modules/.bin/generate-node-app list-page name')
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

        def test_not_available_in_rails
          project_context('app_types/rails')
          output = capture_io do
            assert_raises(ShopifyCli::AbortSilent) do
              run_cmd('generate page test-page')
            end
          end.join

          assert_match('not available here', output)
        end
      end
    end
  end
end
