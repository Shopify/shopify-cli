# typed: ignore
# frozen_string_literal: true

module Script
  module Layers
    module Domain
      module Errors
        class PushPackageNotFoundError < ScriptProjectError; end

        class InvalidExtensionPointError < ScriptProjectError
          attr_reader :type
          def initialize(type)
            super()
            @type = type
          end
        end

        class MissingScriptConfigFieldError < ScriptProjectError
          attr_reader :field
          def initialize(field)
            super()
            @field = field
          end
        end

        class ScriptNotFoundError < ScriptProjectError
          attr_reader :script_name, :extension_point_type
          def initialize(extension_point_type, script_name)
            super()
            @script_name = script_name
            @extension_point_type = extension_point_type
          end
        end

        class MetadataNotFoundError < ScriptProjectError; end

        class MetadataValidationError < ScriptProjectError; end
      end
    end
  end
end
