require 'shopify_cli'

module ShopifyCli
  module Commands
    class Connect < ShopifyCli::Command
      def call(*)
        project_type = ask_project_type unless Project.has_current?

        if Project.has_current? && Project.current && Project.current.env
          @ctx.puts @ctx.message('core.connect.already_connected_warning')
          prod_warning = @ctx.message('core.connect.production_warning')
          @ctx.puts prod_warning if [:rails, :node].include?(Project.current_project_type)
        end

        org = ShopifyCli::Tasks::EnsureEnv.call(@ctx, regenerate: true)
        write_cli_yml(project_type, org['id']) unless Project.has_current?
        api_key = Project.current(force_reload: true).env['api_key']
        @ctx.puts(@ctx.message('core.connect.connected', get_app(org['apps'], api_key).first["title"]))
      end

      def get_app(apps, api_key)
        apps.select { |app| app["apiKey"] == api_key }
      end

      def ask_project_type
        CLI::UI::Prompt.ask(@ctx.message('core.connect.project_type_select')) do |handler|
          ShopifyCli::Commands::Create.all_visible_type.each do |type|
            handler.option(type.project_name) { type.project_type }
          end
        end
      end

      def write_cli_yml(project_type, org_id)
        ShopifyCli::Project.write(
          @ctx,
          project_type: project_type,
          organization_id: org_id,
        )
        @ctx.done(@ctx.message('core.connect.cli_yml_saved'))
      end

      def self.help
        ShopifyCli::Context.message('core.connect.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
