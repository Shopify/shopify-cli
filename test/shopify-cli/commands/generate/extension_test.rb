require 'test_helper'

module ShopifyCli
  module Commands
    class Generate
      class ExtensionTest < MiniTest::Test
        include TestHelpers::Project
        include TestHelpers::FakeUI

        def setup
          super
          @command = ShopifyCli::Commands::Generate::Extension.new(@context)
        end

        def test_marketing_activities_extension
          CLI::UI::Prompt.expects(:ask).returns(:marketing_activities_extension)
          @context.expects(:system).with('generate-marketing-activities-extension')
            .returns(mock(success?: true))
          @command.call(['extension'], nil)
        end
      end
    end
  end
end
