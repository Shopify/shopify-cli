# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Deploy
        def self.call(ctx, language, extension_point_type, script_name, api_key)
          Infrastructure::DeployPackageRepository.new
            .get_deploy_package(ctx, language, extension_point_type, script_name)
            .deploy(Infrastructure::ScriptService.new(ctx: ctx), api_key)
        end
      end
    end
  end
end
