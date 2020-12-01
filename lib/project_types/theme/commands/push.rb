# frozen_string_literal: true
module Theme
  module Commands
    class Push < ShopifyCli::Command
      prerequisite_task :ensure_themekit_installed

      options do |parser, flags|
        parser.on('--remove') { flags['remove'] = true }
        parser.on('--nodelete') { flags['nodelete'] = true }
        parser.on('--allow-live') { flags['allow-live'] = true }
        parser.on('--env=ENV') { |env| flags[:env] = env }
      end

      def call(args, _name)
        if options.flags['remove']
          remove = true
          options.flags.delete('remove')
        end

        if options.flags[:env]
          env = options.flags[:env]
          options.flags.delete(:env)
        end

        flags = Themekit.add_flags(options.flags)

        if remove
          CLI::UI::Frame.open(@ctx.message('theme.push.remove')) do
            unless CLI::UI::Prompt.confirm(@ctx.message('theme.push.remove_confirm'))
              @ctx.abort(@ctx.message('theme.push.remove_abort'))
            end

            unless Themekit.push(@ctx, files: args, flags: flags, remove: remove, env: env)
              @ctx.abort(@ctx.message('theme.push.error.remove_error'))
            end
          end

          @ctx.done(@ctx.message('theme.push.info.remove', @ctx.root))
        else
          CLI::UI::Frame.open(@ctx.message('theme.push.push')) do
            unless Themekit.push(@ctx, files: args, flags: flags, remove: remove, env: env)
              @ctx.abort(@ctx.message('theme.push.error.push_error'))
            end
          end

          @ctx.done(@ctx.message('theme.push.info.push', @ctx.root))
        end
      end

      def self.help
        ShopifyCli::Context.message('theme.push.help', ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end
    end
  end
end
