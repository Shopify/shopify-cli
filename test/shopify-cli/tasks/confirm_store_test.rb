# typed: ignore
require "test_helper"

module ShopifyCLI
  module Tasks
    class ConfirmStoreTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
      end

      def test_aborts_if_no_shop_stored
        ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(false)

        exception = assert_raises ShopifyCLI::Abort do
          ConfirmStore.call(@context)
        end
        assert_includes exception.message, "No store found"
      end

      def test_aborts_if_user_says_no
        ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
        CLI::UI::Prompt.stubs(:confirm).returns(false)

        io = capture_io do
          assert_raises ShopifyCLI::AbortSilent do
            ConfirmStore.call(@context)
          end
        end
        assert_includes io.join, @context.message("core.tasks.confirm_store.cancelling")
      end

      def test_does_not_abort_if_user_says_yes
        ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
        fake_store = "not-a-real-shop.shopify.io"
        ShopifyCLI::DB.stubs(:get).with(:shop).returns(fake_store)
        CLI::UI::Prompt.stubs(:confirm).returns(true)

        io = capture_io do
          assert_nothing_raised do
            ConfirmStore.call(@context)
          end
        end
        assert_includes io.join, CLI::UI.fmt(@context.message("core.tasks.confirm_store.confirmation", fake_store))
      end
    end
  end
end
