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

        # look into error_handler to see how the messages are mapped to errors.
        # Check with Kate on the content of any error messages you introduce, as they are important part of DX.
        # I imagine the error msg could say something like: "Internal error.  Please contact Shopify."
        # In fact, in your PR, you should describe all the failure scenarios, with screen shots of the errors for Kate to review.
        class InvalidProjectError < ScriptProjectError; end

        class ScriptUploadError < ScriptProjectError; end
      end
    end
  end
end
