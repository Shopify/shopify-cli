require 'test_helper'

module ShopifyCli
  module Commands
    class UpdateTest < MiniTest::Test
      def test_calls_update
        ShopifyCli::Core::Update.expects(:check_now).with(
          restart_command_after_update: false,
          ctx: @context,
        )
        run_cmd('update')
      end
    end
  end
end
