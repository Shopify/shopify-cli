# frozen_string_literal: true
module Rails
  class Command
    class Serve < ShopifyCLI::SubCommand
      prerequisite_task ensure_project_type: :rails
      prerequisite_task :ensure_env, :ensure_dev_store

      options do |parser, flags|
        parser.on("--host=HOST") do |h|
          flags[:host] = h.gsub('"', "")
        end
      end

      def call(*)
        project = ShopifyCLI::Project.current
        url = options.flags[:host] || ShopifyCLI::Tunnel.start(@ctx)
        @ctx.abort(@ctx.message("rails.serve.error.host_must_be_https")) if url.match(/^https/i).nil?
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
          env["PORT"] = ShopifyCLI::Tunnel::PORT.to_s
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
