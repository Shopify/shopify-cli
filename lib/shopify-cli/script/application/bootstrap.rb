# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Bootstrap
        def self.call(language, extension_point_type, script_name)
          extension_point = Infrastructure::ExtensionPointRepository
            .new(Infrastructure::ScriptService.new)
            .get_extension_point(extension_point_type)

          script = Infrastructure::ScriptRepository
            .new
            .create_script(language, extension_point, script_name)

          Infrastructure::TestSuiteRepository
            .new
            .create_test_suite(script)

          script
        end
      end
    end
  end
end
