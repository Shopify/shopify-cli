# frozen_string_literal: true

module Script
  module Layers
    module Application
      class DisableScript
        def self.call(ctx:, api_key:, shop_domain:, extension_point_type:)
          script_service = Infrastructure::ScriptService.new(ctx: ctx)
          script_service.disable(
            api_key: api_key,
            shop_domain: shop_domain,
            extension_point_type: extension_point_type,
          )
          ctx.puts(ctx.message('script.application.disabled'))
        end
      end
    end
  end
end
