# frozen_string_literal: true
require_relative "theme"

require "socket"
require "securerandom"

module ShopifyCli
  module Theme
    class DevelopmentTheme < Theme
      def id
        ShopifyCli::DB.get(:development_theme_id)
      end

      def name
        ShopifyCli::DB.get(:development_theme_name) || generate_theme_name
      end

      def ensure_exists!
        create unless exists?

        @ctx.debug("Using temporary development theme: ##{id} #{name}")
      end

      def exists?
        return false unless id

        ShopifyCli::AdminAPI.rest_request(
          @ctx,
          shop: shop,
          path: "themes/#{id}.json",
          api_version: "unstable",
        )
      rescue ShopifyCli::API::APIRequestNotFoundError
        false
      end

      private

      def create
        _status, body = ShopifyCli::AdminAPI.rest_request(
          @ctx,
          shop: shop,
          path: "themes.json",
          body: JSON.generate({
            theme: {
              name: name,
              role: "development",
            },
          }),
          method: "POST",
          api_version: "unstable",
        )

        theme_id = body["theme"]["id"]

        @ctx.debug("Created temporary development theme: #{theme_id}")

        ShopifyCli::DB.set(development_theme_id: theme_id)
      end

      def generate_theme_name
        hostname = Socket.gethostname.split(".").shift
        hash = SecureRandom.hex(3)

        theme_name = "Development (#{hash}-#{hostname})"

        ShopifyCli::DB.set(development_theme_name: theme_name)

        theme_name
      end
    end
  end
end
