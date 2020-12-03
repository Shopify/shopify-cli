# frozen_string_literal: true

module Extension
  module Models
    class TypeDeclaration
      include SmartProperties

      property! :name, accepts: String
      property! :type, accepts: Symbol

      def load_type
        @loaded_type ||= Extension::Models::Type.load_type(type)
      end
    end
  end
end
