# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module BackoffHelper
      def initialize_backoff_helper!(margin: 2, backoff_delay: 2)
        @margin = margin
        @backoff_delay = backoff_delay
        @backoff_mutex = Mutex.new
      end

      def backoff_if_near_limit!(response)
        # Check if the API told us we're near the rate limit
        return if backingoff? || !response

        limit = response.fetch("x-shopify-shop-api-call-limit", "0/999")
        used, total = limit.split("/").map(&:to_i)

        backoff! if used > total - @margin
      end

      def wait_for_backoff!
        # Sleeping in the mutex in another thread. Wait for unlock
        backoff_mutex.synchronize {} if backingoff?
      end

      def backoff!
        ctx.debug("Near API call limit, waiting #{@backoff_delay} seconds")
        backoff_mutex.synchronize { wait(@backoff_delay) }
      end

      def backingoff?
        backoff_mutex.locked?
      end

      def backoff_mutex
        @backoff_mutex || raise("Backoff helper must be initialized")
      end

      private

      def wait(seconds)
        sleep(seconds)
      end
    end
  end
end
