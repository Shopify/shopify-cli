# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Tasks
    module Converters
      module TypeDeclarationConverter
        TYPE_FIELD = 'type'
        NAME_FIELD = 'name'
        FEATURES_FIELD = 'features'
        FEATURES_ARGO_FIELD = 'argo'
        FEATURES_ARGO_SURFACE_FIELD = 'surface'

        def self.from_array(context, from_array)
          context.abort(context.message('tasks.errors.parse_error')) unless from_array.is_a?(Array)

          from_array.map { |declaration_hash| from_hash(context, declaration_hash) }
        end

        def self.from_hash(context, hash)
          context.abort(context.message('tasks.errors.parse_error')) unless hash.is_a?(Hash)

          Models::TypeDeclaration.new(
            type: hash[TYPE_FIELD].to_sym,
            name: hash[NAME_FIELD]
          )
        end
      end
    end
  end
end
