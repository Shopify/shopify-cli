# frozen_string_literal: true
require "test_helper"

module Extension
  module Models
    class ValidationErrorTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)

        @error = ValidationError.new(field: ["Hi"], message: "message")
      end

      def test_field_only_accepts_an_array_of_strings
        assert_raises(SmartProperties::InvalidValueError) { ValidationError.new(field: [1], message: "") }
        assert_raises(SmartProperties::InvalidValueError) { ValidationError.new(field: [Object], message: "") }
        assert_raises(SmartProperties::InvalidValueError) { ValidationError.new(field: ["field", 1], message: "") }

        assert_nothing_raised { ValidationError.new(field: [], message: "") }
        assert_nothing_raised { ValidationError.new(field: ["field"], message: "") }
        assert_nothing_raised { ValidationError.new(field: %w(field1 field2), message: "") }
      end

      def test_is_validation_error_returns_true_if_an_object_is_a_validation_error
        refute Models::ValidationError::IS_VALIDATION_ERROR.call(Object)
        refute Models::ValidationError::IS_VALIDATION_ERROR.call(nil)
        refute Models::ValidationError::IS_VALIDATION_ERROR.call([])

        assert Models::ValidationError::IS_VALIDATION_ERROR.call(@error)
      end

      def test_is_validation_error_list_returns_true_if_an_object_is_a_list_of_validation_errors
        refute Models::ValidationError::IS_VALIDATION_ERROR_LIST.call(nil)
        refute Models::ValidationError::IS_VALIDATION_ERROR_LIST.call(Object)
        refute Models::ValidationError::IS_VALIDATION_ERROR_LIST.call([Object])
        refute Models::ValidationError::IS_VALIDATION_ERROR_LIST.call([@error, 1])

        assert Models::ValidationError::IS_VALIDATION_ERROR_LIST.call([])
        assert Models::ValidationError::IS_VALIDATION_ERROR_LIST.call([@error])
        assert Models::ValidationError::IS_VALIDATION_ERROR_LIST.call(Array.new(2) { @error })
      end
    end
  end
end
