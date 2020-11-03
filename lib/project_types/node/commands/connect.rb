# frozen_string_literal: true
module Node
  module Commands
    class Connect < ShopifyCli::SubCommand
      def call(*)
        if ShopifyCli::Project.has_current? && ShopifyCli::Project.current.env
          @ctx.puts(@ctx.message('core.connect.production_warning'))
        end

        org, api_key = ShopifyCli::Commands::Connect.default_connect('node')
        @ctx.puts(@ctx.message('core.connect.connected', get_app(org['apps'], api_key).first["title"]))
      end
      
      private

      def get_app(apps, api_key)
        apps.select { |app| app["apiKey"] == api_key }
      end

      def write_cli_yml(project_type, org_id)
        ShopifyCli::Project.write(
          @ctx,
          project_type: project_type,
          organization_id: org_id,
        )
        @ctx.done(@ctx.message('core.connect.cli_yml_saved'))
      end
    end
  end
end
