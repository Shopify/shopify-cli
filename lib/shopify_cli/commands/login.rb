require "shopify_cli"

module ShopifyCLI
  module Commands
    class Login < ShopifyCLI::Command
      PROTOCOL_REGEX = /^https?\:\/\//
      PERMANENT_DOMAIN_SUFFIX = /\.myshopify\.(com|io)$/

      options do |parser, flags|
        parser.on("--store=STORE") { |url| flags[:shop] = url }
        # backwards compatibility allow 'shop' for now
        parser.on("--shop=SHOP") { |url| flags[:shop] = url }
        parser.on("--password=PASSWORD") { |password| flags[:password] = password }
      end

      def call(*)
        shop = (options.flags[:shop] || @ctx.getenv("SHOPIFY_SHOP" || nil))
        if shop.nil? && Shopifolk.check
          Shopifolk.reset
          @ctx.puts(@ctx.message("core.tasks.select_org_and_shop.identified_as_shopify"))
          message = @ctx.message("core.tasks.select_org_and_shop.first_party")
          if CLI::UI::Prompt.confirm(message, default: false)
            Shopifolk.act_as_shopify_organization
          end
        end

        # As password auth will soon be deprecated, we enable only in CI
        if @ctx.ci? && (password = options.flags[:password] || @ctx.getenv("SHOPIFY_PASSWORD"))
          ShopifyCLI::DB.set(shopify_exchange_token: password)
        else
          IdentityAuth.new(ctx: @ctx).authenticate
          org = select_organization
          ShopifyCLI::DB.set(organization_id: org["id"].to_i) unless org.nil?

        end
        # validate that shop belongs to organization
        ShopifyCLI::DB.set(shop: self.class.validate_shop(shop, org, context: @ctx)) unless shop.nil?
        Whoami.call([], "whoami")
      end

      def self.help
        ShopifyCLI::Context.message("core.login.help", ShopifyCLI::TOOL_NAME)
      end

      def self.validate_shop(shop, org, context:)
        is_verified = false
        permanent_domain = shop_to_permanent_domain(shop)
        context.abort(context.message("core.login.invalid_shop", shop)) unless permanent_domain
        stores_owned = org["stores"]
        stores_owned.each do |store|
          if permanent_domain == store["shopDomain"]
            is_verified = true
            break
          end
        end
        context.abort(context.message("core.login.invalid_shop", shop)) unless is_verified
        permanent_domain
      end

      def self.shop_to_permanent_domain(shop)
        url = if PROTOCOL_REGEX =~ shop
          shop
        elsif shop.include?(".")
          "https://#{shop}"
        else
          "https://#{shop}.myshopify.com"
        end

        # Make a request to see if it exists or if we get redirected to the permanent domain one
        uri = URI.parse(url)
        Net::HTTP.start(uri.host, use_ssl: true) do |http|
          response = http.request_head("/admin")
          case response
          when Net::HTTPSuccess, Net::HTTPSeeOther
            uri.host
          when Net::HTTPFound
            domain = URI.parse(response["location"]).host
            if PERMANENT_DOMAIN_SUFFIX =~ domain
              domain
            end
          end
        end
      end

      private

      def select_organization
        organizations = ShopifyCLI::PartnersAPI::Organizations.fetch_all(@ctx)

        if organizations.count == 0
          nil
        elsif organizations.count == 1
          organizations.first
        else
          org_id = CLI::UI::Prompt.ask(@ctx.message("core.tasks.select_org_and_shop.organization_select")) do |handler|
            organizations.each do |o|
              handler.option(@ctx.message("core.partners_api.org_name_and_id", o["businessName"], o["id"])) { o["id"] }
            end
          end
          organizations.find { |o| o["id"] == org_id }
        end
      end
    end
  end
end
