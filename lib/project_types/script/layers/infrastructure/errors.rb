# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Errors
        class AppNotInstalledError < ScriptProjectError; end
        class BuildError < ScriptProjectError; end
        class ConfigUiSyntaxError < ScriptProjectError; end

        class ConfigUiMissingKeysError < ScriptProjectError
          attr_reader :filename, :missing_keys
          def initialize(filename, missing_keys)
            super()
            @filename = filename
            @missing_keys = missing_keys
          end
        end

        class ConfigUiInvalidInputModeError < ScriptProjectError
          attr_reader :filename, :valid_input_modes
          def initialize(filename, valid_input_modes)
            super()
            @filename = filename
            @valid_input_modes = valid_input_modes
          end
        end

        class ConfigUiFieldsMissingKeysError < ScriptProjectError
          attr_reader :filename, :missing_keys
          def initialize(filename, missing_keys)
            super()
            @filename = filename
            @missing_keys = missing_keys
          end
        end

        class ConfigUiFieldsInvalidTypeError < ScriptProjectError
          attr_reader :filename, :valid_types
          def initialize(filename, valid_types)
            super()
            @filename = filename
            @valid_types = valid_types
          end
        end

        class DependencyInstallError < ScriptProjectError; end
        class DeprecatedEPError < ScriptProjectError; end
        class EmptyResponseError < ScriptProjectError; end
        class ForbiddenError < ScriptProjectError; end
        class InvalidContextError < ScriptProjectError; end

        class InvalidLanguageError < ScriptProjectError
          attr_reader :language, :extension_point_type
          def initialize(language, extension_point_type)
            super()
            @language = language
            @extension_point_type = extension_point_type
          end
        end

        class GraphqlError < ScriptProjectError
          attr_reader :errors
          def initialize(errors)
            @errors = errors
            super("GraphQL failed with errors: #{errors}")
          end
        end

        class ProjectCreatorNotFoundError < ScriptProjectError; end

        class SystemCallFailureError < ScriptProjectError
          attr_reader :out, :cmd
          def initialize(out:, cmd:)
            super(out)
            @out = out
            @cmd = cmd
          end
        end

        class ScriptRepushError < ScriptProjectError
          attr_reader :uuid
          def initialize(uuid)
            super()
            @uuid = uuid
          end
        end

        class ScriptProjectAlreadyExistsError < ScriptProjectError; end
        class ShopAuthenticationError < ScriptProjectError; end
        class TaskRunnerNotFoundError < ScriptProjectError; end
        class BuildScriptNotFoundError < ScriptProjectError; end
        class InvalidBuildScriptError < ScriptProjectError; end

        class WebAssemblyBinaryNotFoundError < ScriptProjectError
          def initialize
            super("WebAssembly binary not found")
          end
        end
      end
    end
  end
end
