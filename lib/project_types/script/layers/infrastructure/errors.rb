# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Errors
        class AppNotInstalledError < ScriptProjectError; end
        class AppScriptNotPushedError < ScriptProjectError; end
        class AppScriptUndefinedError < ScriptProjectError; end
        class BuildError < ScriptProjectError; end
        class DependencyInstallError < ScriptProjectError; end
        class ForbiddenError < ScriptProjectError; end
        class GraphqlError < ScriptProjectError
          attr_reader :errors
          def initialize(errors)
            @errors = errors
            super("GraphQL failed with errors: #{errors}")
          end
        end
        class ProjectCreatorNotFoundError < ScriptProjectError; end
        class ScriptRepushError < ScriptProjectError
          attr_reader :api_key
          def initialize(api_key)
            super()
            @api_key = api_key
          end
        end
        class ScriptServiceUserError < ScriptProjectError
          def initialize(query_name, errors)
            super("Failed performing #{query_name}. Errors: #{errors}.")
          end
        end
        class ShopAuthenticationError < ScriptProjectError; end
        class ShopScriptConflictError < ScriptProjectError; end
        class ShopScriptUndefinedError < ScriptProjectError; end
        class TaskRunnerNotFoundError < ScriptProjectError; end
        class PackagesOutdatedError < ScriptProjectError
          attr_reader :outdated_packages
          def initialize(outdated_packages)
            super("EP packages are outdated and need to be updated: #{outdated_packages.join(', ')}")
            @outdated_packages = outdated_packages
          end
        end
        class UnmetCompilationDepdencyError < ScriptProjectError; end
      end
    end
  end
end
