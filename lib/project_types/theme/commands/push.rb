# frozen_string_literal: true
module Theme
  module Commands
    class Push < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--remove') { flags['remove'] = true }
        parser.on('--nodelete') { flags['nodelete'] = true }
        parser.on('--allow-live') { flags['allow-live'] = true }
      end

      def call(args, _name)
        if options.flags['remove']
          remove = true
          options.flags.delete('remove')
          action = 'remov'
        else
          action = 'push'
        end

        flags = options.flags.map do |key, _value|
          '--' + key
        end

        CLI::UI::Frame.open(@ctx.message('theme.checking_themekit')) do
          Themekit.ensure_themekit_installed(@ctx)
        end

        CLI::UI::Frame.open(@ctx.message("theme.push.#{action}ing")) do
          unless Themekit.push(@ctx, files: args, flags: flags, remove: remove)
            @ctx.abort(@ctx.message("theme.push.error.#{action}ing_error"))
          end
        end

        @ctx.done(@ctx.message("theme.push.info.#{action}ed", @ctx.root))
      end

      def self.help
        ShopifyCli::Context.message('theme.push.help', ShopifyCli::TOOL_NAME, ShopifyCli::TOOL_NAME)
      end
    end
  end
end
