# frozen_string_literal: true
module Dev
  module Commands
    class Serve < ShopifyCli::Command
      prerequisite_task :ensure_env

      options do |parser, flags|
        parser.on('--host=HOST') { |h| flags[:host] = h.gsub('"', '') }
      end

      def call(*)
        project = ShopifyCli::Project.current
        url = options.flags[:host] || ShopifyCli::Tunnel.start(@ctx)
        @ctx.abort(@ctx.message('dev.serve.error.host_must_be_https')) if url.match(/^https/i).nil?
        project.env.update(@ctx, :host, url)
        ShopifyCli::Tasks::UpdateDashboardURLS.call(
          @ctx,
          url: url,
          callback_url: "/auth/callback",
        )
        serve_cmd = project.config['serve_cmd']
        @ctx.abort('didnt find a serve_cmd in your .shopify-cli.yml') if serve_cmd.nil?
        CLI::UI::Frame.open(@ctx.message('dev.serve.running_server')) do
          @ctx.system(project.config['serve_cmd'], env: project.env.to_h.tap do |env|
            env['PORT'] = ShopifyCli::Tunnel::PORT.to_s
          end)
        end
      end

      def self.help
        ShopifyCli::Context.message('dev.serve.help', ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message('dev.serve.extended_help')
      end
    end
  end
end
