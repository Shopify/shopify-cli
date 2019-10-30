# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Serve < ShopifyCli::Command
      include ShopifyCli::Helpers::OS
      prerequisite_task :ensure_env
      options do |parser, flags|
        parser.on('--host=HOST') do |h|
          flags[:host] = h
        end
      end

      def call(*)
        project = Project.current
        custom_host = options.flags[:host]
        update_env(custom_host) if custom_host
        url = if custom_host
            custom_host
        else
          ShopifyCli::Tasks::Tunnel.call(@ctx)
        end
        ShopifyCli::Tasks::UpdateWhitelistURL.call(@ctx, url: url)
        if mac? && project.env.shop
          @ctx.puts("{{*}} Press {{yellow: Control-T}} to open this project in your browser")
          on_siginfo do
            open = Open.new(@ctx)
            open.call
          end
        end
        CLI::UI::Frame.open('Running server...') do
          @ctx.system(project.app_type.serve_command(@ctx))
        end
      end

      def self.help
        <<~HELP
          Start a local development server for your project, as well as a public ngrok tunnel to your localhost.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} serve}}
        HELP
      end

      def update_env(host)
        env = Helpers::EnvFile.read(@ctx.root)
        Helpers::EnvFile.new(
          api_key: env.api_key,
          secret: env.secret,
          shop: env.shop,
          scopes: env.scopes,
          host: host
        ).write(@ctx)
      end

      def on_siginfo
        fork do
          begin
            r, w = IO.pipe
            @signal = false
            trap('SIGINFO') do
              @signal = true
              w.write(0)
            end
            while r.read(1)
              next unless @signal
              @signal = false
              yield
            end
          rescue Interrupt
            exit(0)
          end
        end
      end
    end
  end
end
