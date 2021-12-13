# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Errors
        class BuildError < ScriptProjectError; end
        class ScriptConfigSyntaxError < ScriptProjectError; end

        class ScriptConfigMissingKeysError < ScriptProjectError
          attr_reader :missing_keys
          def initialize(missing_keys)
            super()
            @missing_keys = missing_keys
          end
        end

        class ScriptConfigInvalidValueError < ScriptProjectError
          attr_reader :valid_input_modes
          def initialize(valid_input_modes)
            super()
            @valid_input_modes = valid_input_modes
          end
        end

        class ScriptConfigFieldsMissingKeysError < ScriptProjectError
          attr_reader :missing_keys
          def initialize(missing_keys)
            super()
            @missing_keys = missing_keys
          end
        end

        class ScriptConfigFieldsInvalidValueError < ScriptProjectError
          attr_reader :valid_types
          def initialize(valid_types)
            super()
            @valid_types = valid_types
          end
        end

        class InvalidScriptConfigYmlDefinitionError < ScriptProjectError; end

        class InvalidScriptJsonDefinitionError < ScriptProjectError; end

        class MissingScriptConfigYmlFieldError < ScriptProjectError
          attr_reader :field
          def initialize(field)
            super()
            @field = field
          end
        end

        class MissingScriptJsonFieldError < ScriptProjectError
          attr_reader :field
          def initialize(field)
            super()
            @field = field
          end
        end

        class NoScriptConfigYmlFileError < ScriptProjectError; end
        class NoScriptConfigFileError < ScriptProjectError; end

        class APILibraryNotFoundError < ScriptProjectError
          attr_reader :library_name
          def initialize(library_name)
            super()
            @library_name = library_name
          end
        end

        class LanguageLibraryForAPINotFoundError < ScriptProjectError
          attr_reader :language, :api
          def initialize(language:, api:)
            super()
            @language = language
            @api = api
          end
        end

        class DeprecatedEPError < ScriptProjectError
          attr_reader(:extension_point)
          def initialize(extension_point)
            super()
            @extension_point = extension_point
          end
        end

        class DependencyInstallError < ScriptProjectError; end
        class EmptyResponseError < ScriptProjectError; end
        class InvalidResponseError < ScriptProjectError; end
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
        class TaskRunnerNotFoundError < ScriptProjectError; end
        class BuildScriptNotFoundError < ScriptProjectError; end

        class WebAssemblyBinaryNotFoundError < ScriptProjectError
          def initialize
            super("WebAssembly binary not found")
          end
        end

        class InvalidProjectError < ScriptProjectError; end

        class ScriptUploadError < ScriptProjectError; end
        class ProjectConfigNotFoundError < ScriptProjectError; end
        class InvalidProjectConfigError < ScriptProjectError; end
      end
    end
  end
end
