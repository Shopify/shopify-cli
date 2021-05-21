# frozen_string_literal: true

module PHP
  module Commands
    class Connect < ShopifyCli::SubCommand
      def call(*)
        if ShopifyCli::Project.has_current? && ShopifyCli::Project.current.env
          @ctx.puts(@ctx.message("php.connect.production_warning"))
        end

        app = ShopifyCli::Commands::Connect.new.default_connect(:php)
        @ctx.done(@ctx.message("php.connect.connected", app))
      end
    end
  end
end
