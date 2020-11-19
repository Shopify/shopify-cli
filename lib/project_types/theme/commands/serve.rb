# frozen_string_literal: true
module Theme
  module Commands
    class Serve < ShopifyCli::Command
      prerequisite_task :ensure_themekit_installed

      options do |parser, flags|
        parser.on('--env=ENV') { |env| flags[:env] = env }
        parser.on('--allow-live') { flags['allow-live'] = true }
        parser.on('--notify') { flags['notify'] = true }
      end

      def call(*)
        CLI::UI::Frame.open(@ctx.message('theme.checking_themekit')) do
          Themekit.ensure_themekit_installed(@ctx)
        end

        if options.flags['env']
          env = options.flags['env']
          options.flags.delete('env')
        end

        flags = options.flags.map do |key, _value|
          '--' + key
        end

        CLI::UI::Frame.open(@ctx.message('theme.serve.serve')) do
          Themekit.serve(@ctx, flags: flags, env: env)
        end
      end

      def self.help
        ShopifyCli::Context.message('theme.serve.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
