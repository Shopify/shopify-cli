# frozen_string_literal: true

require "test_helper"
require "shopify_cli/thread_pool/job"

module ShopifyCLI
  class ThreadPool
    class JobTest < MiniTest::Test
      include TestHelpers::Partners

      def test_perform_with_a_valid_job
        job = ValidJob.new
        assert job.perform!
      end

      def test_perform_with_an_invalid_job
        job = InvalidJob.new

        expected_error = "`ShopifyCLI::ThreadPool::JobTest::InvalidJob#perform!' must be defined"
        actual_error = assert_raises(RuntimeError) { job.perform! }.message

        assert_equal(expected_error, actual_error)
      end

      def test_error
        job = ErrorJob.new
        job.call

        assert_equal "error message", job.error.message
      end

      def test_error?
        error_job = ErrorJob.new
        success_job = ValidJob.new

        error_job.call
        success_job.call

        assert error_job.error?
        refute success_job.error?
      end

      def test_success?
        error_job = ErrorJob.new
        success_job = ValidJob.new

        error_job.call
        success_job.call

        refute error_job.success?
        assert success_job.success?
      end

      def test_recurring_when_it_returns_true
        job = ValidJob.new(1)

        assert(job.recurring?)
        assert_equal(1, job.interval)
      end

      def test_recurring_when_it_returns_false
        job = ValidJob.new

        refute(job.recurring?)
        assert_equal(0, job.interval)
      end

      class ValidJob < ShopifyCLI::ThreadPool::Job
        def perform!
          true
        end
      end

      class InvalidJob < ShopifyCLI::ThreadPool::Job
        # Without `#perform!` definition
      end

      class ErrorJob < ShopifyCLI::ThreadPool::Job
        def perform!
          raise "error message"
        end
      end
    end
  end
end
