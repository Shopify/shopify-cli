require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class PageTest < MiniTest::Test
        include TestHelpers::Project
        include TestHelpers::FakeUI

        def setup
          super
          @command = ShopifyCli::Commands::Generate::Page
          @command.ctx = @context
        end

        def test_run
          CLI::UI::Prompt.expects(:ask).returns(:empty_state)
          @context.expects(:system).with('generate-app empty-state-page name')
            .returns(mock(success?: true))
          @command.call(['page', 'name'], nil)
        end
      end
    end
  end
end
