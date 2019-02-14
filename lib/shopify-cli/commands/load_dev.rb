require 'shopify_cli'

module ShopifyCli
  module Commands
    class LoadDev < ShopifyCli::Command
      def call(args, _name)
        project_dir = File.expand_path(args.shift || Dir.pwd)
        ShopifyCli::Finalize.reload_shopify_from(project_dir)
      end

      def self.help
        "load development instance of shopify-cli from the given path"
      end
    end
  end
end
