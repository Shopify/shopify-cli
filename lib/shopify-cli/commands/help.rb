require 'shopify_cli'

module ShopifyCli
  module Commands
    class Help < ShopifyCli::Command
      def call(args, _name)
        command = args.shift
        if command && command != 'help'
          if Registry.exist?(command)
            cmd, _name = Registry.lookup_command(command)
            output = cmd.help
            if cmd.respond_to?(:extended_help)
              output += "\n"
              output += cmd.extended_help
            end

            @ctx.page(output)
            return
          else
            @ctx.puts("Command #{command} not found.")
          end
        end

        # a line break before output aids scanning/readability
        puts ""
        @ctx.puts('{{bold:Available commands}}')
        @ctx.puts('Use {{command:shopify help [command]}} to display detailed information about a specific command.')
        puts ""

        ShopifyCli::Commands::Registry.resolved_commands.sort.each do |name, klass|
          next if name == 'help'
          next unless klass.available?
          puts CLI::UI.fmt("{{command:#{ShopifyCli::TOOL_NAME} #{name}}}")
          if (help = klass.help)
            puts CLI::UI.fmt(help)
          end
          puts ""
        end
      end
    end
  end
end
