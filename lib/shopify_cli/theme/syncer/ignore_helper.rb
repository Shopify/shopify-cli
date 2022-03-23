# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      module IgnoreHelper
        def ignore_operation?(operation)
          path = operation.file_path
          ignore_path?(path)
        end

        def ignore_file?(file)
          path = file.path
          ignore_path?(path)
        end

        def ignore_path?(path)
          ignored_by_ignore_filter?(path) || ignored_by_include_filter?(path)
        end

        private

        def ignored_by_ignore_filter?(path)
          ignore_filter&.ignore?(path)
        end

        def ignored_by_include_filter?(path)
          !!include_filter && !include_filter.match?(path)
        end
      end
    end
  end
end
