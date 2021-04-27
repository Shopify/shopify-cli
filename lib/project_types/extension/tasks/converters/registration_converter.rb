# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module Converters
      module RegistrationConverter
        ID_FIELD = "id"
        UUID_FIELD = "uuid"
        TYPE_FIELD = "type"
        TITLE_FIELD = "title"
        DRAFT_VERSION_FIELD = "draftVersion"

        def self.from_hash(context, hash)
          context.abort(context.message("tasks.errors.parse_error")) if hash.nil?

          Models::Registration.new(
            id: hash[ID_FIELD].to_i,
            uuid: hash[UUID_FIELD],
            type: hash[TYPE_FIELD],
            title: hash[TITLE_FIELD],
            draft_version: VersionConverter.from_hash(context, hash[DRAFT_VERSION_FIELD])
          )
        end
      end
    end
  end
end
