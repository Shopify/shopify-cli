# frozen_string_literal: true

require "test_helper"
require "shopify_cli/thread_pool"
require "shopify_cli/thread_pool/job"

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
        job = RegularJob.new do
          mutex.synchronize { actual[i] = i }
        end

        thread_pool.schedule(job)
      end

      thread_pool.shutdown

      assert_equal(expected, actual)
    end

    def test_schedule_with_a_recurring_job
      mutex = Mutex.new
      actual_executions = 0
      expected_executions = 3
      thread_pool = ShopifyCLI::ThreadPool.new
      thread_pool.stubs(:wait).returns(nil)

      job = RecurringJob.new do
        mutex.synchronize { actual_executions += 1 }
      end

      job.stubs(:recurring?).returns(true, true, false)

      thread_pool.schedule(job)

      with_retries(Minitest::Assertion) { assert_equal(expected_executions, actual_executions) }
    ensure
      thread_pool.shutdown
    end

    private

    def with_retries(*exceptions, retries: 5)
      yield
    rescue *exceptions
      retries -= 1
      if retries > 0
        sleep(0.1)
        retry
      else
        raise
      end
    end

    class RegularJob < ShopifyCLI::ThreadPool::Job
      def initialize(interval = 0, &block)
        super(interval)
        @perform = block
      end

      def perform!
        @perform.call
      end
    end

    class RecurringJob < RegularJob
      def initialize(&block)
        super(0.1, &block)
      end
    end
  end
end
