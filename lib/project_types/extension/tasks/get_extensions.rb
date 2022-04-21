# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class GetExtensions < ShopifyCLI::Task
      def call(context:, type:)
        org_id = ShopifyCLI::DB.get(:organization_id)
        return [] unless org_id

        organizations = ShopifyCLI::PartnersAPI::Organizations.fetch_with_extensions(context, type, id: org_id)
        extensions_from_organizations(organizations, context: context)
      end

      private

      def extensions_from_organizations(organizations, context:)
        organizations.flat_map do |organization|
          extensions_owned_by_organization(organization, context: context)
        end
      end

      def extensions_owned_by_organization(organization, context:)
        return [] unless organization.key?("apps") && organization["apps"].any?

        organization["apps"].flat_map do |app|
          app["extensionRegistrations"].map do |registration|
            [Converters::AppConverter.from_hash(app, organization),
             Converters::RegistrationConverter.from_hash(context, registration)]
          end
        end
      end
    end
  end
end
