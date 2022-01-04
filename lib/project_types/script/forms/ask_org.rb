# typed: ignore
# frozen_string_literal: true

module Script
  module Forms
    class AskOrg < ShopifyCLI::Form
      attr_reader :org

      BUSINESS_NAME = "businessName"
      ID = "id"

      def ask
        orgs = @xargs
        @org =
          if orgs.count == 1
            orgs.first.tap do |org|
              ctx.puts(ctx.message("script.application.ensure_env.organization", org[BUSINESS_NAME], org[ID]))
            end
          elsif orgs.count > 0
            CLI::UI::Prompt.ask(ctx.message("script.application.ensure_env.organization_select")) do |handler|
              orgs.each do |org|
                handler.option("#{org[BUSINESS_NAME]} (#{org[ID]})") { org }
              end
            end
          else
            raise Errors::NoExistingOrganizationsError
          end
      end
    end
  end
end
