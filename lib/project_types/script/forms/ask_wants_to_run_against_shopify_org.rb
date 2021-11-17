# frozen_string_literal: true

module Script
  module Forms
    class AskWantsToRunAgainstShopifyOrg < ShopifyCLI::Form
      attr_reader :response
      def ask
        @ctx.puts(@ctx.message("core.tasks.select_org_and_shop.identified_as_shopify"))
        message = @ctx.message("core.tasks.select_org_and_shop.first_party")
        @response = CLI::UI::Prompt.confirm(message, default: false)
      end
    end
  end
end
