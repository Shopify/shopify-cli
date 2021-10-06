# frozen_string_literal: true
module Node
  class Command
    class Serve < ShopifyCLI::Command::AppSubCommand
      include ShopifyCLI::CommandOptions::CommandServeOptions

      prerequisite_task ensure_project_type: :node
      prerequisite_task :ensure_env, :ensure_dev_store

      parse_host_option
      parse_port_option

      def call(*)
        project = ShopifyCLI::Project.current
        tunnel_port = port.to_s
        url = host || ShopifyCLI::Tunnel.start(@ctx, port: tunnel_port)
        project.env.update(@ctx, :host, url)
        ShopifyCLI::Tasks::UpdateDashboardURLS.call(
          @ctx,
          url: url,
          callback_url: "/auth/callback",
        )

        if project.env.shop
          project_url = "#{project.env.host}/auth?shop=#{project.env.shop}"
          @ctx.puts("\n" + @ctx.message("node.serve.open_info", project_url) + "\n")
        end

        CLI::UI::Frame.open(@ctx.message("node.serve.running_server")) do
          env = project.env.to_h
          env["PORT"] = tunnel_port
          @ctx.system("npm run dev", env: env)
        end
      end

      def self.help
        ShopifyCLI::Context.message("node.serve.help", ShopifyCLI::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCLI::Context.message("node.serve.extended_help")
      end
    end
  end
end
