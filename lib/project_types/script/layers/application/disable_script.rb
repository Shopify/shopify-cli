# frozen_string_literal: true

module Script
  module Layers
    module Application
      class DisableScript
        def self.call(ctx:, api_key:, shop_domain:, extension_point_type:)
          UI::PrintingSpinner.spin(ctx, ctx.message("script.application.disabling")) do |p_ctx, spinner|
            script_service = Infrastructure::ScriptService.new(ctx: p_ctx)
            script_service.disable(
              api_key: api_key,
              shop_domain: shop_domain,
              extension_point_type: extension_point_type,
            )
            spinner.update_title(p_ctx.message("script.application.disabled"))
          end
        end
      end
    end
  end
end
