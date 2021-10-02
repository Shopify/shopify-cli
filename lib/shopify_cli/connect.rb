require "shopify_cli"

module ShopifyCLI
  class Connect
    def initialize(ctx)
      @ctx = ctx
    end

    def default_connect(project_type)
      if Project.current&.env
        @ctx.puts(@ctx.message("core.connect.already_connected_warning"))
      end
      org = ShopifyCLI::Tasks::EnsureEnv.call(@ctx, regenerate: true)
      write_cli_yml(project_type, org["id"]) unless Project.has_current?
      api_key = Project.current(force_reload: true).env["api_key"]
      get_app(org["apps"], api_key).first["title"]
    end

    def write_cli_yml(project_type, org_id)
      ShopifyCLI::Project.write(
        @ctx,
        project_type: project_type,
        organization_id: org_id,
      )
      @ctx.done(@ctx.message("core.connect.cli_yml_saved"))
    end

    def get_app(apps, api_key)
      apps.select { |app| app["apiKey"] == api_key }
    end
  end
end
