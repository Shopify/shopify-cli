# frozen_string_literal: true

module Script
  module Layers
    module Application
      class DisableScript
        DISABLING_MSG = "Disabling"
        DISABLED_MSG = "Disabled"

        def self.call(ctx:, api_key:, shop_domain:, extension_point_type:)
          UI::StrictSpinner.spin(DISABLING_MSG) do |spinner|
            script_service = Infrastructure::ScriptService.new(ctx: ctx)
            script_service.disable(
              api_key: api_key,
              shop_domain: shop_domain,
              extension_point_type: extension_point_type,
            )
            spinner.update_title(DISABLED_MSG)
          end
        end
      end
    end
  end
end
