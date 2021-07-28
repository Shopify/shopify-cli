# frozen_string_literal: true
module PHP
  class Command
    class Connect < ShopifyCli::SubCommand
      def call(*)
        if ShopifyCli::Project.has_current? && ShopifyCli::Project.current.env
          @ctx.puts(@ctx.message("php.connect.production_warning"))
        end

        app = ShopifyCli::Connect.new(@ctx).default_connect("php")
        @ctx.done(@ctx.message("php.connect.connected", app))
      end

      def self.help
        ShopifyCli::Context.message("php.connect.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end
    end
  end
end
