# typed: ignore
# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module ExecuteCommands
      class Base
        include SmartProperties
        property! :type, accepts: Models::DevelopmentServerRequirements::SUPPORTED_EXTENSION_TYPES
      end
    end
  end
end
