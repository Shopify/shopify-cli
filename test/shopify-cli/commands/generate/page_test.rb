require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class PageTest < MiniTest::Test
        include TestHelpers::Project

        def setup
          super
          @command = ShopifyCli::Commands::Generate.new(@context)
        end

        def test_run
          @context.expects(:system).with('page-generate name')
            .returns(mock(success?: true))
          @command.call(['page', 'name'], nil)
        end
      end
    end
  end
end
