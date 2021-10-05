# frozen_string_literal: true
module Rails
  class Command
    class Serve < ShopifyCLI::Command::AppSubCommand
      include ShopifyCLI::CommandOptions::CommandServeOptions

      prerequisite_task ensure_project_type: :rails
      prerequisite_task :ensure_env, :ensure_dev_store

      parse_host_option
      parse_port_option

      def call(*)
        project = ShopifyCLI::Project.current
        url = host || ShopifyCLI::Tunnel.start(@ctx, port: port)
        project.env.update(@ctx, :host, url)
        ShopifyCLI::Tasks::UpdateDashboardURLS.call(
          @ctx,
          url: url,
          callback_url: "/auth/shopify/callback",
        )

        if project.env.shop
          project_url = "#{project.env.host}/login?shop=#{project.env.shop}"
          @ctx.puts("\n" + @ctx.message("rails.serve.open_info", project_url) + "\n")
        end

        CLI::UI::Frame.open(@ctx.message("rails.serve.running_server")) do
          env = ShopifyCLI::Project.current.env.to_h
          env.delete("HOST")
          env["PORT"] = port.to_s
          env["GEM_PATH"] = Gem.gem_path(@ctx)
          if @ctx.windows?
            @ctx.system("ruby bin\\rails server", env: env)
          else
            @ctx.system("bin/rails server", env: env)
          end
        end
      end

      def self.help
        ShopifyCLI::Context.message("rails.serve.help", ShopifyCLI::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCLI::Context.message("rails.serve.extended_help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
