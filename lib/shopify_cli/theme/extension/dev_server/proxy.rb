# frozen_string_literal: true
require_relative "../../dev_server/base_proxy"
require_relative "proxy_helpers/template_param_builder"

module ShopifyCLI
  module Theme
    module Extension
      module DevServer
        class Proxy < ShopifyCLI::Theme::DevServer::BaseProxy
          def initialize(ctx, extension:, theme:)
            super(ctx)
            @extension = extension

            @shop = theme.shop
            @theme_id = theme.id
          end

          private

          def build_replacement_param(env)
            ProxyHelpers::TemplateParamBuilder.new
                                            .with_core_endpoints(@core_endpoints)
                                            .with_extension(@extension)
                                            .with_rack_env(env)
                                            .build
          end
        end
      end
    end
  end
end
