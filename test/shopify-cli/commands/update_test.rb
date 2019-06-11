require 'test_helper'

module ShopifyCli
  module Commands
    class UpdateTest < MiniTest::Test
      include TestHelpers::Context

      def test_calls_update
        ShopifyCli::Update.expects(:check_now).with(
          restart_command_after_update: false,
          ctx: @context,
        )
        cmd = ShopifyCli::Commands::Update.new(@context)
        cmd.call([], nil)
      end
    end
  end
end
