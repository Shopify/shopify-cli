require 'test_helper'

module ShopifyCli
  module Commands
    class LogoutTest < MiniTest::Test
      def test_call_deletes_db_keys_that_exist
        ShopifyCli::DB.expects(:exists?).with(:identity_access_token).returns(true)
        ShopifyCli::DB.expects(:del).with(:identity_access_token).once

        ShopifyCli::DB.expects(:exists?).with(:identity_refresh_token).returns(false)
        ShopifyCli::DB.expects(:del).with(:identity_refresh_token).never

        ShopifyCli::DB.expects(:exists?).with(:identity_exchange_token).returns(true)
        ShopifyCli::DB.expects(:del).with(:identity_exchange_token).once

        ShopifyCli::DB.expects(:exists?).with(:admin_access_token).returns(false)
        ShopifyCli::DB.expects(:del).with(:admin_access_token).never

        ShopifyCli::DB.expects(:exists?).with(:admin_refresh_token).returns(true)
        ShopifyCli::DB.expects(:del).with(:admin_refresh_token).once

        ShopifyCli::DB.expects(:exists?).with(:admin_exchange_token).returns(false)
        ShopifyCli::DB.expects(:del).with(:admin_exchange_token).never

        run_cmd('logout')
      end

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Logout.help)
        run_cmd('help logout')
      end
    end
  end
end
