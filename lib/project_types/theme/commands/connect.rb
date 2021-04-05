# frozen_string_literal: true
module Theme
  module Commands
    class Connect < ShopifyCli::SubCommand
      def call(_args, _name)
        if ShopifyCli::Project.has_current?
          @ctx.abort(@ctx.message("theme.connect.inside_project"))
        end

        ShopifyCli::Project.write(@ctx,
          project_type: "theme",
          organization_id: nil)

        @ctx.done(@ctx.message("theme.connect.connected", @ctx.root))
      end

      def self.help
        ShopifyCli::Context.message("theme.connect.help", ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end
    end
  end
end
