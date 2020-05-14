require 'shopify_cli'

module ShopifyCli
  module Commands
    class LoadDev < ShopifyCli::Command
      hidden_command

      def call(args, _name)
        project_dir = File.expand_path(args.shift || Dir.pwd)
        unless File.exist?(project_dir)
          raise(ShopifyCli::AbortSilent, @ctx.message('core.load_dev.error.project_dir_not_found', project_dir))
        end
        @ctx.done(@ctx.message('core.load_dev.reloading', TOOL_FULL_NAME, project_dir))
        ShopifyCli::Core::Finalize.reload_shopify_from(project_dir)
      end

      def self.help
        ShopifyCli::Context.message('core.load_dev.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
