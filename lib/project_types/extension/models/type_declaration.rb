# frozen_string_literal: true

module Extension
  module Models
    class TypeDeclaration
      include SmartProperties

      property! :type, accepts: Symbol
      property! :name, accepts: String, default: -> { type.to_s }

      property :feature_argo_surface, accepts: Symbol

      def load_type
        @loaded_type ||= Extension::Models::Type.load_type(self)
      end
    end
  end
end
