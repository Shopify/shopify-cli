# frozen_string_literal: true
module Rails
  class Command
    class Connect < ShopifyCli::SubCommand
      prerequisite_task ensure_project_type: :rails

      def call(*)
        if ShopifyCli::Project.has_current? && ShopifyCli::Project.current.env
          @ctx.puts(@ctx.message("rails.connect.production_warning"))
        end

        app = ShopifyCli::Connect.new(@ctx).default_connect("rails")
        @ctx.done(@ctx.message("rails.connect.connected", app))
      end

      def self.help
        ShopifyCli::Context.message("rails.connect.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end
    end
  end
end
