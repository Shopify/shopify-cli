require 'shopify_cli'

module ShopifyCli
  class AppTypeCommand < ShopifyCli::Command
    class << self
      def app_type(identifier, const, path)
        autoload(const, "shopify-cli/commands/#{path}") if path
        app_type_lookup[self] ||= {}
        app_type_lookup[self][identifier] = const_get(const)
      end

      def app_type_lookup
        @app_type_lookup ||= {}
      end
    end

    def call(args, command_name)
      project = Project.current
      cmd_klass = self.class.app_type_lookup[self.class][project.app_type_id]
      unless cmd_klass
        @ctx.error("{{command:#{command_name}}} not supported in #{project.app_type_id} apps}}")
      end
      cmd = cmd_klass.new
      cmd.ctx = @ctx
      cmd.options = options
      cmd.call(args, command_name)
    end
  end
end
