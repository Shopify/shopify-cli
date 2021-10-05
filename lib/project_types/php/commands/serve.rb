# frozen_string_literal: true
module PHP
  class Command
    class Serve < ShopifyCLI::SubCommand
      PORT = 3000

      prerequisite_task :ensure_env, :ensure_dev_store

      options do |parser, flags|
        parser.on("--host=HOST") do |h|
          flags[:host] = h.gsub('"', "")
        end
      end

      def call(*)
        project = ShopifyCLI::Project.current
        url = options.flags[:host] || ShopifyCLI::Tunnel.start(@ctx, port: PORT)
        @ctx.abort(@ctx.message("php.serve.error.host_must_be_https")) if url.match(/^https/i).nil?
        project.env.update(@ctx, :host, url)
        ShopifyCLI::Tasks::UpdateDashboardURLS.call(
          @ctx,
          url: url,
          callback_url: "/auth/callback",
        )

        if project.env.shop
          project_url = "#{project.env.host}/login?shop=#{project.env.shop}"
          @ctx.puts("\n" + @ctx.message("php.serve.open_info", project_url) + "\n")
        end

        CLI::UI::Frame.open(@ctx.message("php.serve.running_server")) do
          if ShopifyCLI::ProcessSupervision.running?(:npm_watch)
            ShopifyCLI::ProcessSupervision.stop(:npm_watch)
          end
          ShopifyCLI::ProcessSupervision.start(:npm_watch, "npm run watch", force_spawn: true)

          env = project.env.to_h
          @ctx.system("php", "artisan", "serve", "--port", PORT.to_s, env: env)
        end
      end

      def self.help
        ShopifyCLI::Context.message("php.serve.help", ShopifyCLI::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCLI::Context.message("php.serve.extended_help")
      end
    end
  end
end
