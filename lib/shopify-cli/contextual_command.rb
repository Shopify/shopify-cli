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

      def app_type?
        Project.directory(Dir.pwd) && app_type_lookup[self]
      end

      def app_type(identifier, const, path)
        autoload(const, "shopify-cli/commands/#{path}") if path
        app_type_lookup[self] ||= {}
        app_type_lookup[self][identifier] = const_get(const)
      end

      def app_type_lookup
        @app_type_lookup ||= {}
      end

      private

      def available
        @available || @available = []
      end
    end
  end
end
