require 'shopify_cli'

module ShopifyCli
  module Commands
    class Help < ShopifyCli::Command
      def call(args, _name)
        command = args.shift
        if command && command != 'help'
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
            @ctx.puts("Command #{command} not found.")
          end
        end

        # a line break before output aids scanning/readability
        @ctx.puts("")
        @ctx.puts('{{bold:Available commands}}')
        @ctx.puts('Use {{command:shopify help [command]}} to display detailed information about a specific command.')
        @ctx.puts("")

        visible_commands = ShopifyCli::Commands::Registry
          .resolved_commands
          .select { |_name, c| !c.hidden }
          .sort

        visible_commands.each do |name, klass|
          next if name == 'help'
          @ctx.puts("{{command:#{ShopifyCli::TOOL_NAME} #{name}}}")
          if (help = klass.help)
            @ctx.puts(help)
          end
          @ctx.puts("")
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
    end
  end
end
