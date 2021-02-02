require 'shopify_cli'

module ShopifyCli
  module Commands
    class Connect < ShopifyCli::Command
      class << self
        def call(args, command_name)
          ProjectType.load_type(args[0]) unless args.empty?
          super
        end

        def help
          ShopifyCli::Context.message('core.connect.help', ShopifyCli::TOOL_NAME)
        end
      end

      def call(args, command_name)
        if Project.has_current? && Project.current&.env
          @ctx.puts(@ctx.message('core.connect.already_connected_warning'))
        end

        project_type = ask_project_type

        klass = ProjectType.load_type(project_type)&.connect_command

        if klass
          klass.ctx = @ctx
          klass.call(args, command_name, 'connect')
        else
          app = default_connect(project_type)
          @ctx.done(@ctx.message('core.connect.connected', app))
        end
      end

      def ask_project_type
        CLI::UI::Prompt.ask(@ctx.message('core.connect.project_type_select')) do |handler|
          ShopifyCli::Commands::Create.all_visible_type.each do |type|
            handler.option(type.project_name) { type.project_type }
          end
        end
      end

      def default_connect(project_type)
        org = ShopifyCli::Tasks::EnsureEnv.call(@ctx, regenerate: true)
        write_cli_yml(project_type, org['id']) unless Project.has_current?
        api_key = Project.current(force_reload: true).env['api_key']
        get_app(org['apps'], api_key).first['title']
      end

      def write_cli_yml(project_type, org_id)
        ShopifyCli::Project.write(
          @ctx,
          project_type: project_type,
          organization_id: org_id,
        )
        @ctx.done(@ctx.message('core.connect.cli_yml_saved'))
      end

      def get_app(apps, api_key)
        apps.select { |app| app["apiKey"] == api_key }
      end
    end
  end
end
