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

        preamble = <<~MESSAGE
          Use {{command:#{ShopifyCli::TOOL_NAME} help <command>}} to display detailed information about a specific command.

          {{bold:Available core commands:}}

        MESSAGE
        @ctx.puts(preamble)

        core_commands.each do |name, klass|
          next if name == 'help'
          @ctx.puts("{{command:#{name}}}: #{klass.help}\n")
        end

        return unless Project.current_project_type && ProjectType.load_type(Project.current_project_type)

        @ctx.puts("{{bold:Project: #{File.basename(Dir.pwd)} (#{project_name})}}")
        @ctx.puts("{{bold:Available commands for #{project_name} projects:}}\n\n")

        local_commands.each do |name, klass|
          next if name == 'help'
          @ctx.puts("{{command:#{name}}}: #{klass.help}\n")
        end
      end

      private

      def project_name
        ProjectType.load_type(Project.current_project_type).project_name
      end

      def core_commands
        resolved_commands
          .select { |_name, c| !c.hidden }
          .select { |_name, c| c.to_s.include?('ShopifyCli::Commands') }
      end

      def local_commands
        resolved_commands
          .reject { |_name, c| c.to_s.include?('ShopifyCli::Commands') }
      end

      def display_help(klass)
        output = klass.help
        if klass.respond_to?(:extended_help)
          output += "\n"
          output += klass.extended_help
        end
        @ctx.puts(output)
      end

      def resolved_commands
        ShopifyCli::Commands::Registry
          .resolved_commands
          .sort
      end
    end
  end
end
