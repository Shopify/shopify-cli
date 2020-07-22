# frozen_string_literal: true

module Script
  module Layers
    module Application
      class EnableScript
        def self.call(ctx:, api_key:, shop_domain:, configuration:, extension_point_type:, title:)
          UI::PrintingSpinner.spin(ctx, ctx.message('script.application.enabling')) do |p_ctx, spinner|
            script_service = Infrastructure::ScriptService.new(ctx: p_ctx)
            script_service.enable(
              api_key: api_key,
              shop_domain: shop_domain,
              configuration: configuration,
              extension_point_type: extension_point_type,
              title: title
            )
            spinner.update_title(p_ctx.message('script.application.enabled'))
          end
        end
      end
    end
  end
end
