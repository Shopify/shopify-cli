require "test_helper"

module ShopifyCli
  module Commands
    class LogoutTest < MiniTest::Test
      def teardown
        ShopifyCli::Shopifolk.expects(:reset).once
        super
      end

      def test_call_deletes_db_keys_that_exist
        ShopifyCli::DB.expects(:del).with(*ShopifyCli::IdentityAuth::IDENTITY_ACCESS_TOKENS)
        ShopifyCli::DB.expects(:del).with(*ShopifyCli::IdentityAuth::EXCHANGE_TOKENS)

        ShopifyCli::DB.expects(:exists?).with(:shop).twice.returns(true)
        ShopifyCli::DB.expects(:del).with(:shop).once
        ShopifyCli::DB.expects(:exists?).with(:organization_id).once.returns(true)
        ShopifyCli::DB.expects(:del).with(:organization_id).once

        ShopifyCli::Shopifolk.expects(:reset).once

        ShopifyCli::DB.expects(:exists?).with(:development_theme_id).returns(true)
        ShopifyCli::DB.expects(:del).with(:development_theme_id).once

        ShopifyCli::DB.expects(:exists?).with(:development_theme_name).returns(true)
        ShopifyCli::DB.expects(:del).with(:development_theme_name).once

        run_cmd("logout")
      end

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Logout.help)
        run_cmd("help logout")
      end
    end
  end
end
