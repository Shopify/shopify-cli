# frozen_string_literal: true

module Extension
  module Messages
    module MessageLoading
      def self.load
        type_specific_messages = load_current_type_messages
        return Messages::MESSAGES if type_specific_messages.nil?

        if type_specific_messages.key?(:overrides)
          ShopifyCLI::Utilities.deep_merge(Messages::MESSAGES, type_specific_messages[:overrides])
        else
          Messages::MESSAGES
        end
      end

      def self.load_current_type_messages
        return unless ShopifyCLI::Project.has_current?
        messages_for_type(
          ShopifyCLI::Project.current.config[Extension::ExtensionProjectKeys::SPECIFICATION_IDENTIFIER_KEY]
        )
      end

      def self.messages_for_type(type_identifier)
        return if type_identifier.nil?

        type_identifier_symbol = type_identifier.downcase.to_sym
        return unless Messages::TYPES.key?(type_identifier_symbol)

        TYPES[type_identifier_symbol]
      end
    end
  end
end
