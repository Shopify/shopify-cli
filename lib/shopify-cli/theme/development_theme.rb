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

      def role
        "development"
      end

      def ensure_exists!
        if exists?
          @ctx.debug("Using temporary development theme: ##{id} #{name}")
        else
          create
          @ctx.debug("Created temporary development theme: #{@id}")
          ShopifyCli::DB.set(development_theme_id: @id)
        end
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

      def delete
        super if exists?
        ShopifyCli::DB.del(:development_theme_id) if ShopifyCli::DB.exists?(:development_theme_id)
        ShopifyCli::DB.del(:development_theme_name) if ShopifyCli::DB.exists?(:development_theme_name)
      end

      def self.delete(ctx)
        new(ctx).delete
      end

      private

      def generate_theme_name
        hostname = Socket.gethostname.split(".").shift
        hash = SecureRandom.hex(3)

        theme_name = "Development (#{hash}-#{hostname})"[0..50]

        ShopifyCli::DB.set(development_theme_name: theme_name)

        theme_name
      end
    end
  end
end
