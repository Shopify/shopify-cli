# frozen_string_literal: true
require_relative "file"
require_relative "ignore_filter"

require "socket"
require "securerandom"

module ShopifyCli
  module Theme
    class Theme
      # Files waiting to be uploaded to the Online Store
      attr_reader :config

      def initialize(ctx, config)
        @ctx = ctx
        @config = config
        @ignore_filter = IgnoreFilter.new(root, patterns: config.ignore_files, files: config.ignores)
      end

      def root
        @config.root
      end

      def id
        ShopifyCli::DB.get(:development_theme_id)
      end

      def name
        ShopifyCli::DB.get(:development_theme_name) || generate_theme_name
      end

      def theme_files
        glob(["**/*.liquid", "**/*.json", "assets/*"])
      end

      def asset_files
        glob("assets/*")
      end

      def liquid_files
        glob("**/*.liquid")
      end

      def json_files
        glob("**/*.json")
      end

      def glob(pattern)
        root.glob(pattern).map { |path| File.new(path, root) }
      end

      def theme_file?(file)
        theme_files.include?(self[file])
      end

      def asset_paths
        asset_files.map(&:relative_path)
      end

      def [](file)
        case file
        when File
          file
        when Pathname
          File.new(file, root)
        when String
          File.new(root.join(file), root)
        end
      end

      def shop
        AdminAPI.get_shop(@ctx)
      end

      def ignore?(file)
        @ignore_filter.match?(self[file].path.to_s)
      end

      def ensure_development_theme_exists!
        create_development_theme unless development_theme_exists?

        @ctx.debug("Using temporary development theme: ##{id} #{name}")
      end

      def editor_url
        "https://#{shop}/admin/themes/#{id}/editor"
      end

      def preview_url
        "https://#{shop}/?preview_theme_id=#{id}"
      end

      private

      def development_theme_exists?
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

      def create_development_theme
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
