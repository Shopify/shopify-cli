require 'cli/kit'

module CLI
  module Kit
    class Resolver
      def initialize(tool_name:, command_registry:)
        @tool_name = tool_name
        @command_registry = command_registry
        @ctx = ShopifyCli::Context.new
      end

      def call(args)
        args = args.dup
        command_name = args.shift

        command, resolved_name = @command_registry.lookup_command(command_name)

        if command.nil?
          command_not_found(command_name)
          raise CLI::Kit::AbortSilent # Already output message
        end

        [command, resolved_name, args]
      end

      private

      def command_not_found(name)
        CLI::UI::Frame.open(@ctx.message('kit.resolver.command_not_found'),
                            color: :red,
                            timing: false) do
          @ctx.puts(@ctx.message('kit.resolver.tool_not_found', @tool_name, name))
        end

        if ShopifyCli::Project.has_current?
          @ctx.puts(@ctx.message('kit.resolver.in_project', 
                                 ShopifyCli::Project.project_name, 
                                 ShopifyCli::Project.current_project_type, 
                                 @tool_name, 
                                 ShopifyCli::Project.current_project_type))
        else
          @ctx.puts(@ctx.message('kit.resolver.not_in_project', @tool_name))
        end

        cmds = commands_and_aliases
        if cmds.all? { |cmd| cmd.is_a?(String) }
          possible_matches = cmds.min_by(2) do |cmd|
            CLI::Kit::Levenshtein.distance(cmd, name)
          end

          # We don't want to match against any possible command
          # so reject anything that is too far away
          possible_matches.reject! do |possible_match|
            CLI::Kit::Levenshtein.distance(possible_match, name) > 3
          end

          # If we have any matches left, tell the user
          if possible_matches.any?
            CLI::UI::Frame.open(@ctx.message('kit.resolver.any_possible_matches'), 
                                timing: false, 
                                color: :blue) do
              possible_matches.each do |possible_match|
                @ctx.puts(@ctx.message('kit.resolver.possible_matches',
                                       @tool_name,
                                       possible_match))
              end
            end
          end
        end
      end

      def commands_and_aliases
        @command_registry.command_names + @command_registry.aliases.keys
      end
    end
  end
end
