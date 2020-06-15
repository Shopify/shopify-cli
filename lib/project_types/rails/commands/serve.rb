# frozen_string_literal: true
module Rails
  module Commands
    class Serve < ShopifyCli::Command
      prerequisite_task :ensure_env, :ensure_dev_store

      options do |parser, flags|
        parser.on('--host=HOST') do |h|
          flags[:host] = h.gsub('"', '')
        end
      end

      def call(*)
        project = ShopifyCli::Project.current
        url = options.flags[:host] || ShopifyCli::Tunnel.start(@ctx)
        @ctx.abort(@ctx.message('rails.serve.error.host_must_be_https')) if url.match(/^https/i).nil?
        project.env.update(@ctx, :host, url)
        ShopifyCli::Tasks::UpdateDashboardURLS.call(
          @ctx,
          url: url,
          callback_url: "/auth/shopify/callback",
        )
        if @ctx.mac? && project.env.shop
          @ctx.puts(@ctx.message('rails.serve.open_info', project.env.shop))
          @ctx.on_siginfo do
            @ctx.open_url!("#{project.env.host}/login?shop=#{project.env.shop}")
          end
        end
        Gem.gem_home(@ctx)
        CLI::UI::Frame.open(@ctx.message('rails.serve.running_server')) do
          env = ShopifyCli::Project.current.env.to_h
          env.delete('HOST')
          env['PORT'] = ShopifyCli::Tunnel::PORT.to_s
          @ctx.system('bin/rails server', env: env)
        end
      end

      def self.help
        ShopifyCli::Context.message('rails.serve.help', ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message('rails.serve.extended_help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
