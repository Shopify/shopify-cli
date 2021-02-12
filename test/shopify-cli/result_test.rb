require 'test_helper'

module ShopifyCli
  module Result
    class ConvenienceConstructorTest < Minitest::Test
      def test_success_constructor
        assert_kind_of(Result::Success, Result.success(1))
      end

      def test_failure_constructor
        assert_kind_of(Result::Failure, Result.failure(1))
      end

      def test_wrap_constructs_a_failure_result_when_given_an_exception
        assert_kind_of(Result::Failure, Result.wrap(RuntimeError.new))
      end

      def test_wrap_constructs_a_success_result_by_default
        assert_kind_of(Result::Success, Result.wrap("Success"))
      end

      def test_wrap_does_not_wrap_another_result
        assert_equal "Success", Result.wrap(Result.wrap("Success")).value
      end

      def test_supports_deferring_result_construction
        assert_kind_of(Result::Success, Result.wrap { "Success" }.call)
      end

      def test_forwards_caller_argument_when_deferring_result_construction
        assert_equal "Success", Result.wrap { |value| value }.call("Success").value
      end

      def test_supports_wrapping_blocks_that_do_not_take_arguments
        assert_equal 1, Result.wrap { 1 }.call.value
      end

      def test_captures_exceptions_and_wraps_them_in_an_error_when_deferring_result_construction
        assert_kind_of(Result::Failure, Result.wrap { raise "Failure" }.call)
      end
    end

    class SuccessTest < Minitest::Test
      def test_describes_its_state_correctly
        assert Success.new(:value).success?
        refute Success.new(:value).failure?
      end

      def test_value_retrieves_the_result_value
        assert_equal :value, Success.new(:value).value
      end

      def test_error_raises_an_unexpected_success_exception
        assert_raises Result::UnexpectedSuccess do
          Success.new(:value).error
        end
      end

      def test_unwrap_returns_the_value
        assert_equal :value, Success.new(:value).unwrap {}
      end

      def test_additional_arguments_to_unwrap_are_ignored
        assert_nothing_raised do
          Success.new(:value).unwrap(:fallback_value)
        end
      end

      def test_map_returns_a_success_result
        Success.new(1).map { |n| n + 1 }.tap do |result|
          assert result.success?
          assert_equal 2, result.value
        end
      end

      def test_map_does_not_capture_exceptions
        assert_raises RuntimeError do
          Success.new(1).map { raise }
        end
      end

      def test_map_raises_if_the_block_returns_an_error
        assert_raises RuntimeError do
          Success.new(1).map { RuntimeError.new }
        end
      end

      def test_map_raises_an_unexpected_failure_when_encountering_a_failure
        assert_raises UnexpectedFailure do |error|
          Success.new("Message").map { |message| Result.failure(message) }
          assert_equal "Message", error.message
        end
      end

      def test_then_returns_the_return_value_of_the_block_unchanged_if_it_is_a_result
        assert Success.new("Success").then { Failure.new("Failure") }.failure?

        Success.new(1).then { |n| Success.new(n + 1) }.tap do |result|
          assert result.success?
          assert_equal 2, result.value
        end
      end

      def test_then_automatically_wraps_the_result_of_the_block
        assert_equal 2, Success.new(1).then { |n| n + 1 }.value
      end

      def test_then_captures_exceptions_and_wraps_them_in_an_error
        assert Success.new(1).then { raise "Failure" }.failure?
      end

      def test_rescue_simply_returns_itself
        success = Success.new(:success)
        called = false
        assert_same(success, success.rescue { called = true })
        refute called
      end
    end

    class FailureTest < Minitest::Test
      def test_describes_its_state_correctly
        refute Failure.new(:value).success?
        assert Failure.new(:value).failure?
      end

      def test_error
        assert_equal :error, Failure.new(:error).error
      end

      def test_value_raises_an_unexpected_failure_exception
        assert_raises Result::UnexpectedFailure do
          Failure.new(:error).value
        end
      end

      def test_unwrap_raises_an_error_if_no_fallback_has_been_provided
        assert_raises ArgumentError do
          Failure.new(:value).unwrap
        end
      end

      def test_unwrap_returns_the_fallback_value
        assert_equal :fallback, Failure.new(:error).unwrap(:fallback)
      end

      def test_unwrap_returns_the_return_value_of_the_block
        error = RuntimeError.new
        assert_equal error, Failure.new(error).unwrap { |err| err }
      end

      def test_unrwap_raises_an_argument_error_when_both_a_fallback_value_and_a_block_are_given
        assert_raises ArgumentError do
          Failure.new(:error).unwrap(:fallback) {}
        end
      end

      def test_map_returns_itself
        error = Failure.new(:error)
        called = false
        assert_same(error, error.map { called = true })
        refute called
      end

      def test_then_simply_returns_itself
        error = Failure.new(:error)
        called = false
        assert_same(error, error.then { called = true })
        refute called
      end

      def test_rescue_returns_the_return_value_of_the_block_unchanged_if_it_is_a_result
        assert Failure.new("Failure").rescue { Success.new("Success") }.success?

        Failure.new(1).rescue { |n| Failure.new(n + 1) }.tap do |result|
          assert result.failure?
          assert_equal 2, result.error
        end
      end

      def test_rescue_automatically_wraps_the_result_of_the_block
        Failure.new(1).rescue { |n| n + 1 }.tap do |result|
          assert result.success?
          assert 2, result.value
        end
      end

      def test_rescue_captures_exceptions_and_wraps_them_in_an_error
        assert Failure.new(1).then { raise "Failure" }.failure?
      end
    end
  end
end
