# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Errors
        class AppNotInstalledError < ScriptProjectError; end
        class BuildError < ScriptProjectError; end
        class ScriptJsonSyntaxError < ScriptProjectError; end

        class ScriptJsonMissingKeysError < ScriptProjectError
          attr_reader :missing_keys
          def initialize(missing_keys)
            super()
            @missing_keys = missing_keys
          end
        end

        class ScriptJsonInvalidValueError < ScriptProjectError
          attr_reader :valid_input_modes
          def initialize(valid_input_modes)
            super()
            @valid_input_modes = valid_input_modes
          end
        end

        class ScriptJsonFieldsMissingKeysError < ScriptProjectError
          attr_reader :missing_keys
          def initialize(missing_keys)
            super()
            @missing_keys = missing_keys
          end
        end

        class ScriptJsonFieldsInvalidValueError < ScriptProjectError
          attr_reader :valid_types
          def initialize(valid_types)
            super()
            @valid_types = valid_types
          end
        end

        class DependencyInstallationError < ScriptProjectError; end
        class MissingDependencyVersionError < ScriptProjectError
          attr_reader :tool, :current_version, :min_version
          def initialize(tool, current_version, min_version)
            super()
            @tool = tool
            @current_version = current_version
            @min_version = min_version
          end
        end
        class NoDependencyInstalledError < ScriptProjectError
          attr_reader :tool, :min_version
          def initialize(tool, min_version)
            super()
            @tool = tool
            @min_version = min_version
          end
        end
        class DeprecatedEPError < ScriptProjectError; end
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
        class ShopAuthenticationError < ScriptProjectError; end
        class TaskRunnerNotFoundError < ScriptProjectError; end
        class BuildScriptNotFoundError < ScriptProjectError; end
        class InvalidBuildScriptError < ScriptProjectError; end

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
