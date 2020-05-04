# frozen_string_literal: true

module Script
  module Layers
    module Application
      class EnableScript
        ENABLING_MSG = "Enabling"
        ENABLED_MSG = "Enabled"

        def self.call(ctx:, api_key:, shop_domain:, configuration:, extension_point_type:, title:)
          UI::StrictSpinner.spin(ENABLING_MSG) do |spinner|
            script_service = Infrastructure::ScriptService.new(ctx: ctx)
            script_service.enable(
              api_key: api_key,
              shop_domain: shop_domain,
              configuration: configuration,
              extension_point_type: extension_point_type,
              title: title
            )
            spinner.update_title(ENABLED_MSG)
          end
        end
      end
    end
  end
end
