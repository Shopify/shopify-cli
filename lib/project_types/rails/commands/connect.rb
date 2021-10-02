# frozen_string_literal: true
module Rails
  class Command
    class Connect < ShopifyCLI::Command::AppSubCommand
      prerequisite_task ensure_project_type: :rails

      def call(*)
        if ShopifyCLI::Project.has_current? && ShopifyCLI::Project.current.env
          @ctx.puts(@ctx.message("rails.connect.production_warning"))
        end

        app = ShopifyCLI::Connect.new(@ctx).default_connect("rails")
        @ctx.done(@ctx.message("rails.connect.connected", app))
      end

      def self.help
        ShopifyCLI::Context.message("rails.connect.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
