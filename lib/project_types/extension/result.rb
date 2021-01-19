# frozen_string_literal: true
# typed: strict

module Extension
  module Result
    class UncheckedError < RuntimeError; end

    class Base
      def initialize(value)
        @value = value
      end
      
      protected

      attr_reader :value
    end

    class Ok < Base
      def ok?
        true
      end

      def error?
        false
      end

      def ok_value
        value
      end

      def ok_value_or(fallback_value)
        value
      end

      def ok_value_or_else(&fallback_block)
        value
      end

      def error_value
        nil
      end

      def and_then(&block)
        new_result = block.call(value)
        return new_result if new_result.is_a?(Base)
        raise TypeError, "Expected result object but received #{new_result.class} instead" 
      end

      def or_else(&block)
        self
      end

      def yield_ok(&block)
        Result.ok(block.call(value))
      end

      def yield_error(&block)
        self
      end
    end

    class Error < Base
      def ok?
        false
      end

      def error?
        true
      end

      def ok_value
        raise UncheckedError
      end

      def ok_value_or(fallback_value)
        fallback_value
      end

      def ok_value_or_else(&fallback_block)
        fallback_block.call(value)
      end

      def error_value
        value
      end

      def and_then(&block)
        self
      end

      def or_else(&block)
        new_result = block.call(value)
        raise TypeError unless new_result.is_a?(Base)
        new_result
      end

      def yield_ok(&block)
        self
      end

      def yield_error(&block)
        Result.error(block.call(value))
      end
    end

    module_function

    def new(&block)
      Ok.new(block.call)
    rescue => error
      Error.new(error)
    end

    def ok(value)
      Ok.new(value)
    end

    def error(value)
      Error.new(value)
    end
  end
end
