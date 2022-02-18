# frozen_string_literal: true

module Theme
  class Command
    module Common
      module ErrorHelper
        def handle_permissions_error(ctx)
          theme = ShopifyCLI::Theme::Theme.new(@ctx)
          @ctx.abort(@ctx.message("theme.serve.ensure_user", theme.shop))
        end
      end
    end
  end
end
