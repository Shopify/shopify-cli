require 'shopify_cli'

module ShopifyCli
  class ContextualCommand < ShopifyCli::Command
    class << self
      def available?
        return true if !Project.directory(Dir.pwd) && available.include?(:top_level)
        return false unless Project.directory(Dir.pwd)
        available.include?(Project.current.config['project_type'])
      end

      def available_in(identifier)
        available << identifier
      end

      private

      def available
        @available || @available = []
      end
    end
  end
end
