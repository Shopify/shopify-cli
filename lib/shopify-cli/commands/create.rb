require 'shopify-cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::Command
      def call(args, _name)
        @name = args.shift
        return puts CLI::UI.fmt(self.class.help) unless @name

        app_type = CLI::UI::Prompt.ask('What type of app would you like to create?') do |handler|
          AppTypeRegistry.each do |identifier, app_type|
            handler.option(app_type.description) { |selection| identifier }
          end
          handler.option('ruby embedded app') { |selection| return false }
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
