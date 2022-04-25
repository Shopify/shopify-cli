# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class GetApps < ShopifyCLI::Task
      def call(context:)
        org_id = ShopifyCLI::DB.get(:organization_id)
        return [] unless org_id

        organization = ShopifyCLI::PartnersAPI::Organizations.fetch_with_apps(context, id: org_id)
        apps_owned_by_organization(organization)
      end

      private

      def apps_owned_by_organization(organization)
        return [] unless organization&.dig("apps")

        organization["apps"].map do |app|
          Converters::AppConverter.from_hash(app, organization)
        end
      end
    end
  end
end
