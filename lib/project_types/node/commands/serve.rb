# frozen_string_literal: true
module Node
  class Command
    class Serve < ShopifyCLI::Command::AppSubCommand
      prerequisite_task ensure_project_type: :node
      prerequisite_task :ensure_env, :ensure_dev_store

      options do |parser, flags|
        parser.on("--host=HOST") do |h|
          flags[:host] = h.gsub('"', "")
        end
        parser.on("--port=PORT") { |port| flags[:port] = port }
      end

      def call(*)
        project = ShopifyCLI::Project.current
        url = options.flags[:host] || ShopifyCLI::Tunnel.start(@ctx)
        @ctx.abort(@ctx.message("node.serve.error.host_must_be_https")) if url.match(/^https/i).nil?
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
          env["PORT"] = port.to_s
          @ctx.system("npm run dev", env: env)
        end
      end

      def port
        return ShopifyCLI::Tunnel::PORT.to_s unless options.flags.key?(:port)
        port = options.flags[:port].to_i
        @ctx.abort(@ctx.message("node.serve.error.invalid_port", options.flags[:port])) unless port > 0
        port
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
