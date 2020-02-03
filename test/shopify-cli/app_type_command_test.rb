require 'test_helper'

module ShopifyCli
  class AppTypeCommandTest < MiniTest::Test
    def setup
      super
      Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
      @cmd = ShopifyCli::Commands::Serve
      @cmd.ctx = @context
    end

    def test_non_existant_command
      assert_raises(ShopifyCli::Abort) do
        @cmd.call([], 'serve')
      end
    end
  end
end
