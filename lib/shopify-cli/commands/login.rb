require "shopify_cli"

module ShopifyCli
  module Commands
    class Login < ShopifyCli::Command
      PROTOCOL_REGEX = /^https?\:\/\//
      PERMANENT_DOMAIN_SUFFIX = /\.myshopify\.(com|io)$/

      options do |parser, flags|
        parser.on("--shop=SHOP") do |shop|
          flags[:shop] = shop
        end
        parser.on("--password=PASSWORD") do |password|
          flags[:password] = password
        end
      end

      def call(*)
        if Shopifolk.check
          @ctx.puts(@ctx.message("core.tasks.select_org_and_shop.identified_as_shopify"))
          message = @ctx.message("core.tasks.select_org_and_shop.first_party")
          if CLI::UI::Prompt.confirm(message, default: false)
            Shopifolk.act_as_shopify_organization
          else
            ShopifyCli::Shopifolk.reset
          end
        end
        shop = (options.flags[:shop] || @ctx.getenv("SHOPIFY_SHOP") || nil)
        ShopifyCli::DB.set(shop: self.class.validate_shop(shop)) unless shop.nil?

        # As password auth will soon be deprecated, we enable only in CI
        if @ctx.ci? && (password = options.flags[:password] || @ctx.getenv("SHOPIFY_PASSWORD"))
          ShopifyCli::DB.set(shopify_exchange_token: password)
        else
          IdentityAuth.new(ctx: @ctx).authenticate
        end
      end

      def self.help
        ShopifyCli::Context.message("core.login.help", ShopifyCli::TOOL_NAME)
      end

      def self.validate_shop(shop)
        permanent_domain = shop_to_permanent_domain(shop)
        @ctx.abort(@ctx.message("core.login.invalid_shop", shop)) unless permanent_domain
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
    end
  end
end
