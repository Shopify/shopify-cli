# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class GetExtensions < ShopifyCLI::Task
      def call(context:, type:)
        org_id = ShopifyCLI::DB.get(:organization_id)
        return [] unless org_id

        organization = ShopifyCLI::PartnersAPI::Organizations.fetch_with_extensions(context, type, id: org_id)
        return [] unless organization_with_apps?(organization)
        extensions_owned_by_organization(organization, context: context)
      end

      private

      def extensions_owned_by_organization(organization, context:)
        organization["apps"].flat_map do |app|
          registrations = app["extensionRegistrations"] || []
          registrations.map do |registration|
            [Converters::AppConverter.from_hash(app, organization),
             Converters::RegistrationConverter.from_hash(context, registration)]
          end
        end
      end

      def organization_with_apps?(organization)
        organization&.key?("apps") && organization["apps"].any?
      end
    end
  end
end
