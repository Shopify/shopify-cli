# frozen_string_literal: true
module Rails
  module Commands
    class Connect < ShopifyCli::SubCommand
      def call(*)
        if ShopifyCli::Project.has_current? && ShopifyCli::Project.current.env
          @ctx.puts(@ctx.message('core.connect.production_warning'))
        end

        org, api_key = ShopifyCli::Commands::Connect.default_connect('rails')
        @ctx.done(@ctx.message('core.connect.connected', get_app(org['apps'], api_key).first["title"]))
      end

      private

      def get_app(apps, api_key)
        apps.select { |app| app["apiKey"] == api_key }
      end
    end
  end
end
