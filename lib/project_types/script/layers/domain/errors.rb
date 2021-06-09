# frozen_string_literal: true

module Script
  module Layers
    module Domain
      module Errors
        class PushPackageNotFoundError < ScriptProjectError; end

        class InvalidScriptApiError < ScriptProjectError
          attr_reader :type
          def initialize(type)
            super()
            @type = type
          end
        end

        class InvalidConfigUiDefinitionError < ScriptProjectError
          attr_reader :filename
          def initialize(filename)
            super()
            @filename = filename
          end
        end

        class MissingSpecifiedConfigUiDefinitionError < ScriptProjectError
          attr_reader :filename
          def initialize(filename)
            super()
            @filename = filename
          end
        end

        class ScriptNotFoundError < ScriptProjectError
          attr_reader :script_name, :script_api_type
          def initialize(script_api_type, script_name)
            super()
            @script_name = script_name
            @script_api_type = script_api_type
          end
        end

        class MetadataNotFoundError < ScriptProjectError; end

        class MetadataValidationError < ScriptProjectError; end
      end
    end
  end
end
