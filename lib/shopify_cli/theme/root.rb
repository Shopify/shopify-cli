# frozen_string_literal: true
require_relative "file"
require "pathname"

module ShopifyCLI
  module Theme
    class Root
      attr_reader :root, :ctx

      def initialize(ctx, root:)
        @ctx = ctx
        @root = Pathname.new(root) if root
      end

      def static_asset_files
        glob("assets/*", raise_on_dir: true).reject(&:liquid?)
      end

      def liquid_files
        glob("**/*.liquid")
      end

      def json_files
        glob("**/*.json")
      end

      def glob(pattern, raise_on_dir: false)
        root
          .glob(pattern)
          .select { |path| file?(path, raise_on_dir) }
          .map { |path| File.new(path, root) }
      end

      def static_asset_file?(file)
        static_asset_files.include?(self[file])
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

      def file?(path, raise_on_dir = false)
        if raise_on_dir && ::File.directory?(path)
          @ctx.abort(@ctx.message("theme.serve.error.invalid_subdirectory", path.to_s))
        end

        ::File.file?(path)
      end
    end
  end
end
