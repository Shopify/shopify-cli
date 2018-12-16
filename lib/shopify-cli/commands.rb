require 'shopify-cli'

module ShopifyCli
  module Commands
    autoload :Server,  'dev/commands/server'

    module ContextualResolver
      def self.aliases
        Dev::Project.current.local_aliases.merge(Dev::Config.get_section("command-alias"))
      end

      def self.command_names
        project = Dev::Project.current
        project.local_commands + project.type_commands.keys + defined_api_commands.keys
      end

      def self.command_class(name)
        defined_api_commands.fetch(name, Dev::Commands::ProjectLocal)
      end

      def self.defined_api_commands
        api_commands = {
          'test' => Test,
          'server' => Server,
          'console' => Console,
          'build' => Build,
        }
        api_commands.select { |_name, klass| klass.defined? }
      end
    end

    Registry = CLI::Kit::CommandRegistry.new(
      default: 'help',
      contextual_resolver: ContextualResolver
    )

    def self.register(constant, as: nil) # register(:MyAPIThing)
      basename = CLI::Kit::Util.snake_case(constant)
      as ||= CLI::Kit::Util.dash_case(constant)
      path = File.join('dev/commands', basename)
      autoload(constant, path) # ...(:MyAPIThing, "dev/commands/my_api_thing")
      Registry.add(->() { const_get(constant) }, as) # ...(->() { MyAPIThing }, "my-api-thing")
    end
  end
end
