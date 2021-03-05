# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module Converters
      module ValidationErrorConverter
        FIELD_FIELD = "field"
        MESSAGE_FIELD = "message"

        def self.from_array(context, errors)
          return [] if errors.nil?
          context.abort(context.message("tasks.errors.parse_error")) unless errors.is_a?(Array)

          errors.map do |error|
            Models::ValidationError.new(
              field: error[FIELD_FIELD],
              message: error[MESSAGE_FIELD]
            )
          end
        end
      end
    end
  end
end
