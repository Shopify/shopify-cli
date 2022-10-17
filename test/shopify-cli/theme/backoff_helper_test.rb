# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/backoff_helper"

module ShopifyCLI
  module Theme
    class BackoffHelperTest < Minitest::Test
      include BackoffHelper

      def setup
        super
        initialize_backoff_helper!
      end

      def test_backoff_if_near_limit_when_it_is_near_limit
        expects(:backoff!)

        backoff_if_near_limit!("x-shopify-shop-api-call-limit" => "39/40")
      end

      def test_backoff_if_near_limit_when_it_is_not_near_limit
        expects(:backoff!).never

        backoff_if_near_limit!("x-shopify-shop-api-call-limit" => "37/40")
      end

      def test_backoff_if_near_limit_when_response_is_invalid
        expects(:backoff!).never

        backoff_if_near_limit!(nil)
      end

      def test_backoff_if_near_limit_when_response_is_empty
        expects(:backoff!).never

        backoff_if_near_limit!({})
      end

      def test_backoff_if_near_limit_when_it_is_backingoff
        stubs(:backingoff?).returns(true)
        expects(:backoff!).never

        backoff_if_near_limit!("x-shopify-shop-api-call-limit" => "39/40")
      end

      def test_wait_for_backoff
        stubs(:backingoff?).returns(true, false)

        backoff_mutex.expects(:synchronize).once

        2.times { wait_for_backoff! }
      end

      def test_backoff
        expects(:wait).with(2)

        ctx.expects(:debug).with("Near API call limit, waiting 2 seconds")

        backoff!
      end

      def test_is_backingoff
        backoff_mutex.stubs(:locked?).returns(true, false)

        assert(backingoff?)
        refute(backingoff?)
      end

      private

      def ctx
        @context
      end
    end
  end
end
