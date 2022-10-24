# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class BulkRequest
          def initialize(theme, bulk_items)
            @theme = theme
            @bulk_items = bulk_items
          end

          def to_h
            {
              path: "themes/#{@theme.id}/assets/bulk.json",
              method: "PUT",
              body: JSON.generate({ assets: assets }),
            }
          end

          private

          def assets
            @bulk_items.map(&:asset)
          end
        end
      end
    end
  end
end
