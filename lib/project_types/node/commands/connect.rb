# frozen_string_literal: true
module Node
  class Command
    class Connect < ShopifyCLI::SubCommand
      prerequisite_task ensure_project_type: :node

      def call(*)
        if ShopifyCLI::Project.has_current? && ShopifyCLI::Project.current.env
          @ctx.puts(@ctx.message("node.connect.production_warning"))
        end

        app = ShopifyCLI::Connect.new(@ctx).default_connect("node")
        @ctx.done(@ctx.message("node.connect.connected", app))
      end

      def self.help
        ShopifyCLI::Context.message("node.connect.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
