# frozen_string_literal: true
module PHP
  class Command
    class Connect < ShopifyCLI::SubCommand
      def call(*)
        if ShopifyCLI::Project.has_current? && ShopifyCLI::Project.current.env
          @ctx.puts(@ctx.message("php.connect.production_warning"))
        end

        app = ShopifyCLI::Connect.new(@ctx).default_connect("php")
        @ctx.done(@ctx.message("php.connect.connected", app))
      end

      def self.help
        ShopifyCLI::Context.message("php.connect.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
