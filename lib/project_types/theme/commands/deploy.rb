# frozen_string_literal: true
module Theme
  module Commands
    class Deploy < ShopifyCli::Command
      prerequisite_task :ensure_themekit_installed

      options do |parser, flags|
        parser.on('--env=ENV') { |env| flags[:env] = env }
        parser.on('--allow-live') { flags['allow_live'] = true }
      end

      def call(*)
        CLI::UI::Frame.open(@ctx.message('theme.deploy.deploying')) do
          unless CLI::UI::Prompt.confirm(@ctx.message('theme.deploy.confirmation'))
            @ctx.abort(@ctx.message('theme.deploy.abort'))
          end

          if options.flags[:env]
            env = options.flags[:env]
            options.flags.delete(:env)
          end

          flags = Themekit.add_flags(options.flags)

          unless Themekit.deploy(@ctx, flags: flags, env: env)
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
