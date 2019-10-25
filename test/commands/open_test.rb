require 'test_helper'

module ShopifyCli
  module Commands
    class OpenTest < MiniTest::Test
      include TestHelpers::Project

      def setup
        super
        @command = ShopifyCli::Commands::Open.new(@context)
      end

      def test_run
        @command.expects(:open_url!).with(@context, 'https://example.com')
        @command.call([], nil)
      end
    end
  end
end
