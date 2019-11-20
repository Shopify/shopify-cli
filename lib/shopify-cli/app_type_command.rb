require 'shopify_cli'

module ShopifyCli
  class AppTypeCommand < ShopifyCli::Command
    class << self
      def type(identifier, const, path)
        autoload(const, "shopify-cli/commands/#{path}") if path
        lookup[self] ||= {}
        lookup[self][identifier] = const_get(const)
      end

      def lookup
        @lookup ||= {}
      end
    end

    def call(*args)
      project = Project.current
      cmd = self.class.lookup[self.class][project.app_type_id].new
      cmd.ctx = @ctx
      cmd.options = options
      cmd.call(*args)
    end
  end
end
