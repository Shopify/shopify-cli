require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::Command
      def call(args, _name)
        @name = args.shift
        return puts CLI::UI.fmt(self.class.help) unless @name

        app_type = CLI::UI::Prompt.ask('What type of app would you like to create?') do |handler|
        puts CLI::UI.fmt("{{yellow:*}} starting ngrok")
        @ngrok = Helpers::NgrokHelper.start
        puts CLI::UI.fmt("{{yellow:*}} ngrok connected at #{@ngrok}")
          AppTypeRegistry.each do |identifier, type|
            handler.option(type.description) { identifier }
          end
        end

        return puts "not yet implemented" unless app_type

        AppTypeRegistry.build(app_type, @name)
      end

      def self.help
        "Bootstrap an app.\nUsage: {{command:#{ShopifyCli::TOOL_NAME} create <apptype> <appname>}}"
      end
    end
  end
end
