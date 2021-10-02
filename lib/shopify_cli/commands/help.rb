require "shopify_cli"

module ShopifyCLI
  module Commands
    class Help < ShopifyCLI::Command
      def call(args, _name)
        command = args.shift
        if command && command != "help"
          if Registry.exist?(command)
            cmd, _ = Registry.lookup_command(command)
            subcmd, _ = cmd.subcommand_registry.lookup_command(args.first)
            if subcmd
              display_help(subcmd)
            else
              display_help(cmd)
            end
            return
          else
            @ctx.puts(@ctx.message("core.help.error.command_not_found", command))
          end
        end

        preamble = @ctx.message("core.help.preamble", ShopifyCLI::TOOL_NAME)
        @ctx.puts(preamble)

        available_commands = resolved_commands.select { |_name, c| !c.hidden? }

        available_commands.each do |name, klass|
          next if name == "help"
          @ctx.puts("{{command:#{name}}}: #{klass.help}\n")
        end
      end

      private

      def display_help(klass)
        output = klass.help
        if klass.respond_to?(:extended_help)
          output += "\n"
          output += klass.extended_help
        end
        @ctx.puts(output)
      end

      def resolved_commands
        ShopifyCLI::Commands::Registry
          .resolved_commands
          .sort
      end
    end
  end
end
