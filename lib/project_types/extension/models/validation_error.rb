# frozen_string_literal: true

module Extension
  module Models
    class ValidationError
      include SmartProperties

      IS_VALIDATION_ERROR_LIST = -> (errors) do
        errors.is_a?(Array) && errors.all? { |error| IS_VALIDATION_ERROR.call(error) }
      end
      IS_VALIDATION_ERROR = -> (error) { error.is_a?(ValidationError) }

      property! :field, accepts: -> (fields) { fields.all? { |field| field.is_a?(String) } }
      property! :message, accepts: String
    end
  end
end
