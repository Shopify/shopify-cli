require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::Command
      prerequisite_task :tunnel

      def call(args, _name)
        @name = args.shift
        return puts CLI::UI.fmt(self.class.help) unless @name

        app_type = CLI::UI::Prompt.ask('What type of app would you like to create?') do |handler|
          AppTypeRegistry.each do |identifier, type|
            handler.option(type.description) { identifier }
          end
        end

        return puts "not yet implemented" unless app_type

        # we need the concept of "project" probably to hold path state
        @ctx.root = File.join(Dir.pwd, @name)

        AppTypeRegistry.build(app_type, @name, @ctx)
      end

      def self.help
        <<~HELP
          Bootstrap an app.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} create <appname>}}
        HELP
      end
    end
  end
end
