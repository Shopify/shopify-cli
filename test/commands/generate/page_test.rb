require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class PageTest < MiniTest::Test
        include TestHelpers::Context

        def setup
          super
          @command = ShopifyCli::Commands::Generate.new(@context)
        end

        def test_run
          ShopifyCli::Project.write(@context, :node)
          @context.expects(:exec).with('npm run-script generate-page name')
          @command.call(['page', 'name'], nil)
        end
      end
    end
  end
end
