# frozen_string_literal: true
module Node
  module Commands
    class Serve < ShopifyCli::Command
      prerequisite_task :ensure_env, :ensure_test_shop

      options do |parser, flags|
        parser.on('--host=HOST') do |h|
          flags[:host] = h.gsub('"', '')
        end
      end

      def call(*)
        project = ShopifyCli::Project.current
        url = options.flags[:host] || ShopifyCli::Tunnel.start(@ctx)
        @ctx.abort(@ctx.message('node.serve.error.host_must_be_https')) if url.match(/^https/i).nil?
        project.env.update(@ctx, :host, url)
        ShopifyCli::Tasks::UpdateDashboardURLS.call(
          @ctx,
          url: url,
          callback_url: "/auth/callback",
        )
        if @ctx.mac? && project.env.shop
          @ctx.puts(@ctx.message('node.serve.open_info', project.env.shop))
          @ctx.on_siginfo do
            @ctx.open_url!("#{project.env.host}/auth?shop=#{project.env.shop}")
          end
        end
        CLI::UI::Frame.open(@ctx.message('node.serve.running')) do
          env = project.env.to_h
          env['PORT'] = ShopifyCli::Tunnel::PORT.to_s
          @ctx.system('npm run dev', env: env)
        end
      end

      def self.help
        ShopifyCli::Context.message('node.serve.help', ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message('node.serve.extended_help')
      end
    end
  end
end
