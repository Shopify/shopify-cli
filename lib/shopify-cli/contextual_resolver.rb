require 'cli/kit'

module ShopifyCli
  class ContextualResolver < CLI::Kit::Resolver
    def call(args)
      args = args.dup
      return super(args) unless args.first
      if args.first.include?('-h') || args.first.include?('--help')
        help = Commands::Help
        help.ctx = Context.new
        help.call([], nil)
        raise ShopifyCli::AbortSilent
      else
        command_name = args.shift

        command, resolved_name = @command_registry.lookup_command(command_name)

        if command.nil?
          command_not_found(command_name)
          raise CLI::Kit::AbortSilent # Already output message
        end

        unless command.available?
          CLI::UI::Frame.open("Command not available", color: :red, timing: false) do
            $stderr.puts(CLI::UI.fmt("{{command:#{@tool_name} #{command_name}}} not available here"))
          end
          raise CLI::Kit::AbortSilent
        end

        if command.app_type?
          project = Project.current
          cmd = command.app_type_lookup[command][project.app_type_id]
          unless cmd
            $stderr.puts(CLI::UI.fmt("{{command:#{command_name}}} not supported in #{project.app_type_id} apps}}"))
            raise CLI::Kit::AbortSilent
          end
          return [cmd, resolved_name, args]
        end

        [command, resolved_name, args]
      end
    end
  end
end
