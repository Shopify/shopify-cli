# frozen_string_literal: true
module PHP
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
      end

      def call(_args, _name)
        raise NotImplementedError
      end

      def self.help
        ShopifyCli::Context.message("php.create.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
