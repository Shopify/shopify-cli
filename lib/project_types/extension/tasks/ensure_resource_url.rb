# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class EnsureResourceUrl < ShopifyCLI::Task
      include SmartProperties

      property! :context, accepts: ShopifyCLI::Context
      property! :specification_handler, accepts: Extension::Models::SpecificationHandlers::Default

      def self.call(*args)
        new(*args).call
      end

      def call
        project = ExtensionProject.current(force_reload: true)

        ShopifyCLI::Result
          .wrap(project.resource_url)
          .rescue { specification_handler.build_resource_url(shop: project.env.shop, context: context) }
          .then(&method(:persist_resource_url))
          .unwrap do |nil_or_exception|
            case nil_or_exception
            when nil
              context.warn(context.message("warnings.resource_url_auto_generation_failed", project.env.shop))
            else
              context.abort(nil_or_exception)
            end
          end
      end

      def persist_resource_url(resource_url)
        ExtensionProject.update_env_file(context: context, resource_url: resource_url)
        resource_url
      end
    end
  end
end
