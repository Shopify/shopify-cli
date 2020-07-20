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
            @ctx.puts(@ctx.message('core.help.error.command_not_found', command))
          end
        end

        preamble = @ctx.message('core.help.preamble', ShopifyCli::TOOL_NAME)
        @ctx.puts(preamble)

        core_commands.each do |name, klass|
          next if name == 'help'
          @ctx.puts("{{command:#{name}}}: #{klass.help}\n")
        end

        return unless inside_supported_project?

        @ctx.puts("{{bold:Project: #{Project.project_name} (#{project_type_name})}}")
        @ctx.puts("{{bold:Available commands for #{project_type_name} projects:}}\n\n")

        local_commands.each do |name, klass|
          next if name == 'help'
          @ctx.puts("{{command:#{name}}}: #{klass.help}\n")
        end
      end

      private

      def project_type_name
        ProjectType.load_type(Project.current_project_type).project_name
      end

      def core_commands
        resolved_commands
          .select { |_name, c| !c.hidden? }
          .select { |name, _c| Commands.core_command?(name) }
      end

      def local_commands
        resolved_commands
          .reject { |name, _c| Commands.core_command?(name) }
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

      def inside_supported_project?
        Project.current_project_type && ProjectType.load_type(Project.current_project_type)
      end
    end
  end
end
