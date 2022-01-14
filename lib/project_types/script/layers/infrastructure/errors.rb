# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Errors
        class BuildError < ScriptProjectError; end

        class ScriptConfigurationDefinitionError < ScriptProjectError
          attr_reader :filename
          def initialize(message:, filename:)
            @filename = filename
            super(message)
          end
        end

        class ScriptConfigSyntaxError < ScriptProjectError
          attr_reader :filename
          def initialize(filename)
            @filename = filename
            super()
          end
        end

        class ScriptConfigMissingKeysError < ScriptProjectError
          attr_reader :missing_keys, :filename
          def initialize(missing_keys:, filename:)
            super()
            @missing_keys = missing_keys
            @filename = filename
          end
        end

        class ScriptConfigInvalidValueError < ScriptProjectError
          attr_reader :valid_input_modes, :filename
          def initialize(valid_input_modes:, filename:)
            super()
            @valid_input_modes = valid_input_modes
            @filename = filename
          end
        end

        class ScriptConfigFieldsMissingKeysError < ScriptProjectError
          attr_reader :missing_keys, :filename
          def initialize(missing_keys:, filename:)
            super()
            @missing_keys = missing_keys
            @filename = filename
          end
        end

        class ScriptConfigFieldsInvalidValueError < ScriptProjectError
          attr_reader :valid_types, :filename
          def initialize(valid_types:, filename:)
            super()
            @valid_types = valid_types
            @filename = filename
          end
        end

        class ScriptEnvAppNotConnectedError < ScriptProjectError; end

        class ScriptConfigParseError < ScriptProjectError
          attr_reader :filename, :serialization_format
          def initialize(filename:, serialization_format:)
            super()
            @filename = filename
            @serialization_format = serialization_format
          end
        end

        class NoScriptConfigFileError < ScriptProjectError
          attr_reader :filename
          def initialize(filename)
            super()
            @filename = filename
          end
        end

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

        class ScriptTooLargeError < ScriptProjectError
          attr_reader :file_size_limit

          def initialize(file_size_limit)
            super()
            @file_size_limit = file_size_limit
          end

          def humanized_file_size_limit
            if file_size_limit < 1_000
              { unit: "B", file_size_limit: file_size_limit }
            elsif file_size_limit < 1_000_000
              { unit: "KB", file_size_limit: file_size_limit / 1_000 }
            else
              { unit: "MB", file_size_limit: file_size_limit / 1_000_000 }
            end
          end
        end
      end
    end
  end
end
