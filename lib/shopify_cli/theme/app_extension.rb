# frozen_string_literal: true
require_relative "file"
require_relative "theme_admin_api"

require "pathname"
require "time"

module ShopifyCLI
  module Theme
    class AppExtension
      attr_reader :root, :id

      def initialize(ctx, root:, id:)
        @ctx = ctx
        @root = Pathname.new(root)
        @id = id
      end

      def static_asset_files
        glob("assets/*", raise_on_dir: true).reject(&:liquid?)
      end

      def static_asset_file?(file)
        static_asset_files.include?(self[file])
      end

      def shop
        api_client.get_shop_or_abort
      end

      def static_asset_paths
        static_asset_files.map(&:relative_path)
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

      private

      def api_client
        @api_client ||= ThemeAdminAPI.new(@ctx)
      end

      def glob(pattern, raise_on_dir: false)
        root
          .glob(pattern)
          .select { |path| file?(path, raise_on_dir) }
          .map { |path| File.new(path, root) }
      end

      def file?(path, raise_on_dir = false)
        if raise_on_dir && ::File.directory?(path)
          @ctx.abort(@ctx.message("theme.serve.error.invalid_subdirectory", path.to_s))
        end

        ::File.file?(path)
      end
    end
  end
end
