require "test_helper"
require "shopify_cli/theme/development_theme"
require "shopify_cli/theme/extension/host_theme"

module ShopifyCLI
  module Commands
    class LogoutTest < MiniTest::Test
      def teardown
        ShopifyCLI::Shopifolk.expects(:reset).once
        super
      end

      def test_call_deletes_db_keys_that_exist
        stub_identity_deletions
        stub_get_shop_and_org_data
        stub_delete_shop_and_org_data

        ShopifyCLI::Shopifolk.expects(:reset).once

        stub_theme_successful_deletion(:development_theme_id, :development_theme_name)
        stub_theme_successful_deletion(:host_theme_id, :host_theme_name)

        run_cmd("logout")
      end

      def test_call_finishes_if_dev_theme_deletion_fails_and_host_theme_deletion_succeeds
        stub_identity_deletions
        stub_get_shop_and_org_data
        stub_delete_shop_and_org_data
        ShopifyCLI::Shopifolk.expects(:reset).once

        dev_theme_deletion_error = "this is an error"

        ShopifyCLI::Theme::DevelopmentTheme.expects(:delete).once
          .raises(ShopifyCLI::Abort.new(dev_theme_deletion_error))
        @context.expects(:debug).with("[Logout Error]: #{dev_theme_deletion_error}").once

        stub_theme_successful_deletion(:host_theme_id, :host_theme_name)

        @context.expects(:puts).with("Successfully logged out of your account")

        run_cmd("logout")
      end

      def test_call_finishes_if_dev_theme_deletion_succeeds_and_host_theme_deletion_fails
        stub_identity_deletions
        stub_get_shop_and_org_data
        stub_delete_shop_and_org_data
        ShopifyCLI::Shopifolk.expects(:reset).once

        host_theme_deletion_error = "this is an error"

        stub_theme_successful_deletion(:development_theme_id, :development_theme_name)

        ShopifyCLI::Theme::Extension::HostTheme.expects(:delete).once
          .raises(ShopifyCLI::Abort.new(host_theme_deletion_error))
        @context.expects(:debug).with("[Logout Error]: #{host_theme_deletion_error}").once
        @context.expects(:puts).with("Successfully logged out of your account")

        run_cmd("logout")
      end

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCLI::Commands::Logout.help)
        run_cmd("help logout")
      end

      private

      def stub_theme_successful_deletion(id_key, name_key)
        ShopifyCLI::DB.expects(:exists?).with(id_key).returns(true)
        ShopifyCLI::DB.expects(:del).with(id_key).once

        ShopifyCLI::DB.expects(:exists?).with(name_key).returns(true)
        ShopifyCLI::DB.expects(:del).with(name_key).once
      end

      def stub_identity_deletions
        ShopifyCLI::DB.expects(:del).with(*ShopifyCLI::IdentityAuth::IDENTITY_ACCESS_TOKENS)
        ShopifyCLI::DB.expects(:del).with(*ShopifyCLI::IdentityAuth::EXCHANGE_TOKENS)
      end

      def stub_delete_shop_and_org_data
        ShopifyCLI::DB.expects(:del).with(:shop).once
        ShopifyCLI::DB.expects(:del).with(:organization_id).once
      end

      def stub_get_shop_and_org_data
        ShopifyCLI::DB.expects(:exists?).with(:shop).times(3).returns(true)
        ShopifyCLI::DB.expects(:exists?).with(:organization_id).once.returns(true)
      end
    end
  end
end
