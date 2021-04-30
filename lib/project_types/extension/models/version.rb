# frozen_string_literal: true

module Extension
  module Models
    class Version
      include SmartProperties

      property! :registration_id, accepts: Integer
      property! :last_user_interaction_at, accepts: Time
      property  :context, accepts: String
      property  :location, accepts: String
      property :validation_errors, accepts: Models::ValidationError::IS_VALIDATION_ERROR_LIST, default: -> { [] }
    end
  end
end
