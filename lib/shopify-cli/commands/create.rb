require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::Command
      def self.call(args, command_name)
        ProjectType.load_type(args[0]) unless args.empty?
        super
      end

      def call(args, command_name)
        unless args.empty?
          @ctx.puts("{{red:Error}}: invalid app type {{bold:#{args[0]}}}")
          return @ctx.puts(self.class.help)
        end

        type_name = CLI::UI::Prompt.ask('What type of project would you like to create?') do |handler|
          self.class.all_visible_type.each do |type|
            handler.option(type.project_name) { type.project_type }
          end
        end

        klass = ProjectType.load_type(type_name).create_command
        klass.ctx = @ctx
        klass.call(args, command_name, 'create')
      end

      def self.all_visible_type
        ProjectType
          .load_all
          .select { |type| !type.hidden }
      end

      def self.help
        project_types = all_visible_type.map(&:project_type).join(" | ")
        <<~HELP
          Create a new project.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} create [ #{project_types} ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          #{
        all_visible_type.map do |type|
          type.create_command.help
        end.join("\n")
        }
        HELP
      end
    end
  end
end
