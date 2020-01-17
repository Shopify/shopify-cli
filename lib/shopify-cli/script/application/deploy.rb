# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Deploy
        def self.call(ctx, deploy_package, api_key)
          deploy_package.deploy(Infrastructure::ScriptService.new(ctx: ctx), api_key)
        end
      end
    end
  end
end
