# frozen_string_literal: true
require_relative "file"
require_relative "ignore_filter"

module ShopifyCli
  module Theme
    class Theme
      attr_reader :config, :id

      def initialize(ctx, config, id: nil)
        @ctx = ctx
        @config = config
        @id = id
        @ignore_filter = IgnoreFilter.new(root, patterns: config.ignore_files, files: config.ignores)
      end

      def root
        @config.root
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

      def editor_url
        "https://#{shop}/admin/themes/#{id}/editor"
      end

      def preview_url
        "https://#{shop}/?preview_theme_id=#{id}"
      end
    end
  end
end
