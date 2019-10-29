# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Deploy
        def self.call(language, extension_point_type, script_name, shop_id = nil, config_value = nil)
          Infrastructure::DeployPackageRepository.new
            .get_deploy_package(language, extension_point_type, script_name)
            .deploy(Infrastructure::ScriptService.new, shop_id, config_value)
        end
      end
    end
  end
end
