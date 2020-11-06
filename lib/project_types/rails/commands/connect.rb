# frozen_string_literal: true
module Rails
  module Commands
    class Connect < ShopifyCli::SubCommand
      def call(*)
        if ShopifyCli::Project.has_current? && ShopifyCli::Project.current.env
          @ctx.puts(@ctx.message('rails.connect.production_warning'))
        end

        app = ShopifyCli::Commands::Connect.new.default_connect('rails')
        @ctx.done(@ctx.message('rails.connect.connected', app))
      end
    end
  end
end
