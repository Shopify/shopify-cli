# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module Converters
      module VersionConverter
        REGISTRATION_ID_FIELD = "registrationId"
        CONTEXT_FIELD = "context"
        LAST_USER_INTERACTION_AT_FIELD = "lastUserInteractionAt"
        LOCATION_FIELD = "location"
        VALIDATION_ERRORS_FIELD = "validationErrors"

        def self.from_hash(context, hash)
          context.abort(context.message("tasks.errors.parse_error")) if hash.nil?

          Models::Version.new(
            registration_id: hash[REGISTRATION_ID_FIELD].to_i,
            context: hash[CONTEXT_FIELD],
            last_user_interaction_at: Time.parse(hash[LAST_USER_INTERACTION_AT_FIELD]),
            location: hash[LOCATION_FIELD],
            validation_errors: Converters::ValidationErrorConverter.from_array(context, hash[VALIDATION_ERRORS_FIELD])
          )
        end
      end
    end
  end
end
