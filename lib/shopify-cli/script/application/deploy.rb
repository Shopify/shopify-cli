# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Deploy
        def self.call(ctx, language, extension_point_type, script_name, api_key)
          script = ScriptRepository.new.get_script(ctx, language, extension_point_type, script_name)
          content_type = Infrastructure::ScriptBuilder.for(script).compiled_type

          Infrastructure::DeployPackageRepository.new
            .get_deploy_package(script, extension_point_type, script_name, content_type)
            .deploy(Infrastructure::ScriptService.new(ctx: ctx), api_key)
        end
      end
    end
  end
end
