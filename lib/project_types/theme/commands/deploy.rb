# frozen_string_literal: true
module Theme
  module Commands
    class Deploy < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--env=ENV') { |env| flags[:env] = env }
        parser.on('--themekit_opts=OPTS') { |opts| flags[:opts] = opts }
      end

      def call(*)
        CLI::UI::Frame.open(@ctx.message('theme.checking_themekit')) do
          Themekit.ensure_themekit_installed(@ctx)
        end

        CLI::UI::Frame.open(@ctx.message('theme.deploy.deploying')) do
          unless CLI::UI::Prompt.confirm(@ctx.message('theme.deploy.confirmation'))
            @ctx.abort(@ctx.message('theme.deploy.abort'))
          end

          unless Themekit.deploy(@ctx, env: options.flags[:env], opts: options.flags[:opts])
            @ctx.abort(@ctx.message('theme.deploy.error'))
          end
        end

        @ctx.done(@ctx.message('theme.deploy.info.deployed'))
      end

      def self.help
        ShopifyCli::Context.message('theme.deploy.help', ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end
    end
  end
end
