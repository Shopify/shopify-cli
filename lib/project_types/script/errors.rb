# frozen_string_literal: true

module Script
  module Errors
    class InvalidContextError < ScriptProjectError; end
    class InvalidScriptNameError < ScriptProjectError; end
    class NoExistingAppsError < ScriptProjectError; end
    class NoExistingOrganizationsError < ScriptProjectError; end

    class NoExistingStoresError < ScriptProjectError
      attr_reader :organization_id
      def initialize(organization_id)
        super()
        @organization_id = organization_id
      end
    end

    class ScriptProjectAlreadyExistsError < ScriptProjectError; end
    class InvalidConfigProps < ScriptProjectError; end

    class InvalidConfigYAMLError < ScriptProjectError
      attr_reader :config_file
      def initialize(config_file)
        super()
        @config_file = config_file
      end
    end

    class InvalidLanguageError < ScriptProjectError
      attr_reader :language
      def initialize(language)
        super()
        @language = language
      end
    end

    class DeprecatedEPError < ScriptProjectError
      attr_reader :ep
      def initialize(ep)
        super()
        @ep = ep
      end
    end
  end
end
