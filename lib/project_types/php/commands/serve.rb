# frozen_string_literal: true
module PHP
  module Commands
    class Serve < ShopifyCli::Command
      PORT = 3000

      prerequisite_task :ensure_env, :ensure_dev_store

      options do |parser, flags|
        parser.on("--host=HOST") do |h|
          flags[:host] = h.gsub('"', "")
        end
      end

      def call(*)
        project = ShopifyCli::Project.current
        url = options.flags[:host] || ShopifyCli::Tunnel.start(@ctx, port: PORT)
        @ctx.abort(@ctx.message("php.serve.error.host_must_be_https")) if url.match(/^https/i).nil?
        project.env.update(@ctx, :host, url)
        ShopifyCli::Tasks::UpdateDashboardURLS.call(
          @ctx,
          url: url,
          callback_url: "/auth/callback",
        )

        if project.env.shop
          project_url = "#{project.env.host}/login?shop=#{project.env.shop}"
          @ctx.puts("\n" + @ctx.message("php.serve.open_info", project_url) + "\n")
        end

        CLI::UI::Frame.open(@ctx.message("php.serve.running_server")) do
          if ShopifyCli::ProcessSupervision.running?(:npm_watch)
            ShopifyCli::ProcessSupervision.stop(:npm_watch)
          end
          ShopifyCli::ProcessSupervision.start(:npm_watch, "npm run watch", force_spawn: true)

          env = project.env.to_h
          @ctx.system("php", "artisan", "serve", "--port", PORT.to_s, env: env)
        end
      end

      def self.help
        ShopifyCli::Context.message("php.serve.help", ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message("php.serve.extended_help")
      end
    end
  end
end
