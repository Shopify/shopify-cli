require 'shopify_cli'
require 'uri'

module ShopifyCli
  module Forms
    class CreateExtension < Form
      positional_arguments :name
      flag_arguments :type

      ExtensionType = Struct.new(:identifier, :description, keyword_init: true) do
        def ==(extensionType)
          case extensionType
          when String
            self.identifier == extensionType
          else
            super(extensionType)
          end
        end
      end

      EXTENSION_TYPES = [
        ExtensionType.new(identifier: 'product-details', description: 'Product extension'),
        ExtensionType.new(identifier: 'customer-details', description: 'Customer extension')
      ]

      def ask
        self.type = ask_type
      end

      private

      def ask_type
        return type if EXTENSION_TYPES.include?(type)
        ctx.puts('Invalid Extension Type.') unless type.nil?
        CLI::UI::Prompt.ask('What type of extension would you like to create?') do |handler|
          EXTENSION_TYPES.each do |type|
            handler.option(type.description) { type.identifier }
          end
        end
      end
    end
  end
end
