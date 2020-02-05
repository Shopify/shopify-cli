# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Bootstrap
        def self.call(ctx, language, extension_point_type, script_name)
          extension_point = Infrastructure::ExtensionPointRepository
            .new(Infrastructure::ScriptService.new(ctx: ctx))
            .get_extension_point(extension_point_type)

          script = Infrastructure::ScriptRepository
            .new
            .create_script(language, extension_point, script_name)

          Infrastructure::TestSuiteRepository
            .new
            .create_test_suite(script)

          ShopifyCli::Finalize.request_cd(script_name)
          ctx.root = File.join(ctx.root, script.name)
          ShopifyCli::Project.write(ctx, :script,
            'extension_point_type' => extension_point_type, 'script_name' => script_name)
          script
        end
      end
    end
  end
end
