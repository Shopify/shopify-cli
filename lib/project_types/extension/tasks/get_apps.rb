# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class GetApps < ShopifyCLI::Task
      def call(context:)
        organizations = ShopifyCLI::PartnersAPI::Organizations.fetch_all_with_apps(context)
        apps_from_organizations(organizations)
      end

      private

      def apps_from_organizations(organizations)
        organizations.flat_map do |organization|
          apps_owned_by_organization(organization)
        end
      end

      def apps_owned_by_organization(organization)
        return [] unless organization.key?("apps") && organization["apps"].any?

        organization["apps"].map do |app|
          Converters::AppConverter.from_hash(app, organization)
        end
      end
    end
  end
end
