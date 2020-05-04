# frozen_string_literal: true

module Script
  module Errors
    class InvalidContextError < ScriptProjectError; end
    class NoExistingAppsError < ScriptProjectError; end
    class NoExistingOrganizationsError < ScriptProjectError; end
    class NoExistingStoresError < ScriptProjectError
      attr_reader :organization_id
      def initialize(organization_id)
        @organization_id = organization_id
      end
    end
    class ScriptProjectAlreadyExistsError < ScriptProjectError; end
  end
end
