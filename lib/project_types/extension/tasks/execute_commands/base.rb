# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module ExecuteCommands
      class Base
        include SmartProperties

        property! :type, accepts: Models::DevelopmentServerRequirements::SUPPORTED_EXTENSION_TYPES

        def self.inherited(subclass)
          subclass.prepend(OutdatedExtensionDetection)
        end
      end
    end
  end
end
