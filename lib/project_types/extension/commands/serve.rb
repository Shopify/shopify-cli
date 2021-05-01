# frozen_string_literal: true

module Extension
  class Command
    class Serve < ExtensionCommand
      def call(_args, _command_name)
        specification_handler.serve(@ctx)
      end

      def self.help
        ShopifyCli::Context.new.message("serve.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
