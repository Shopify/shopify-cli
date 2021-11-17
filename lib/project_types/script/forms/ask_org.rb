# frozen_string_literal: true

module Script
  module Forms
    class AskOrg < ShopifyCLI::Form
      attr_reader :org

      def ask
        orgs = @xargs
        if orgs.count == 1
          default = orgs.first
          ctx.puts(ctx.message("script.application.ensure_env.organization", default["businessName"],
            default["id"]))
          @org = default
        elsif orgs.count > 0
          CLI::UI::Prompt.ask(ctx.message("script.application.ensure_env.organization_select")) do |handler|
            orgs.each do |org|
              handler.option("#{org["businessName"]} (#{org["id"]})") { @org = org }
            end
          end
        else
          raise Errors::NoExistingOrganizationsError
        end
      end
    end
  end
end
