# frozen_string_literal: true

module Extension
  module Messages
    module MessageLoading
      def self.load
        type_specific_messages = load_current_type_messages
        return Messages::MESSAGES if type_specific_messages.nil?

        if type_specific_messages.key?(:overrides)
          Messages::MESSAGES.merge(type_specific_messages[:overrides])
        else
          Messages::MESSAGES
        end
      end

      def self.load_current_type_messages
        return unless ShopifyCli::Project.has_current?
        messages_for_type(ShopifyCli::Project.current.config[Extension::ExtensionProjectKeys::EXTENSION_TYPE_KEY])
      end

      def self.messages_for_type(type_identifier)
        return if type_identifier.nil?

        type_identifier_symbol = type_identifier.downcase.to_sym
        return unless Messages::TYPES.has_key?(type_identifier_symbol)

        TYPES[type_identifier_symbol]
      end
    end
  end
end
