require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class PageTest < MiniTest::Test
        include TestHelpers::AppType

        def setup
          super
          @command = ShopifyCli::Commands::Generate.new(@context)
        end

        def test_run
          @context.expects(:exec).with('page-generate', 'name')
          @command.call(['page', 'name'], nil)
        end
      end
    end
  end
end
