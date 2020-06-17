# frozen_string_literal: true

module Script
  module Layers
    module Application
      class EnableScript
        def self.call(ctx:, api_key:, shop_domain:, configuration:, extension_point_type:, title:)
          script_service = Infrastructure::ScriptService.new(ctx: ctx)
          script_service.enable(
            api_key: api_key,
            shop_domain: shop_domain,
            configuration: configuration,
            extension_point_type: extension_point_type,
            title: title
          )
          ctx.puts(ctx.message('script.application.enabled'))
        end
      end
    end
  end
end
