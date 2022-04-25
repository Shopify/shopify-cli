require "test_helper"

module ShopifyCLI
  module Commands
    class LogoutTest < MiniTest::Test
      def teardown
        ShopifyCLI::Shopifolk.expects(:reset).once
        super
      end

      def test_call_deletes_db_keys_that_exist
        ShopifyCLI::DB.expects(:del).with(*ShopifyCLI::IdentityAuth::IDENTITY_ACCESS_TOKENS)
        ShopifyCLI::DB.expects(:del).with(*ShopifyCLI::IdentityAuth::EXCHANGE_TOKENS)

        ShopifyCLI::DB.expects(:exists?).with(:shop).twice.returns(true)
        ShopifyCLI::DB.expects(:del).with(:shop).once
        ShopifyCLI::DB.expects(:exists?).with(:organization_id).once.returns(true)
        ShopifyCLI::DB.expects(:del).with(:organization_id).once

        ShopifyCLI::Shopifolk.expects(:reset).once

        ShopifyCLI::DB.expects(:exists?).with(:development_theme_id).returns(true)
        ShopifyCLI::DB.expects(:del).with(:development_theme_id).once

        ShopifyCLI::DB.expects(:exists?).with(:development_theme_name).returns(true)
        ShopifyCLI::DB.expects(:del).with(:development_theme_name).once

        run_cmd("logout")
      end

      def test_call_finishes_if_dev_theme_deletion_fails
        ShopifyCLI::DB.expects(:exists?).with(:shop).twice.returns(true)
        ShopifyCLI::DB.expects(:exists?).with(:organization_id).once.returns(true)
        ShopifyCLI::Theme::DevelopmentTheme.expects(:delete).once.raises(ShopifyCLI::Abort)
        @context.expects(:puts).with("Successfully logged out of your account")

        run_cmd("logout")
      end

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCLI::Commands::Logout.help)
        run_cmd("help logout")
      end
    end
  end
end
