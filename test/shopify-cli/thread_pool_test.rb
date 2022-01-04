# typed: ignore
# frozen_string_literal: true

require "test_helper"
require "shopify_cli/thread_pool"

module ShopifyCLI
  class ThreadPoolTest < MiniTest::Test
    include TestHelpers::Partners

    def test_schedule
      number_of_executions = 10_000
      mutex = Mutex.new
      actual = Array.new(number_of_executions)
      expected = (0...number_of_executions).to_a

      thread_pool = ShopifyCLI::ThreadPool.new

      number_of_executions.times do |i|
        thread_pool.schedule(-> do
          mutex.synchronize { actual[i] = i }
        end)
      end

      thread_pool.shutdown

      assert_equal(expected, actual)
    end
  end
end
