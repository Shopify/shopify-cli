# frozen_string_literal: true

require "shopify_cli/thread_pool/job"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class BulkItem
          attr_reader :file, :block
          attr_accessor :retries

          def initialize(file, &block)
            @file = file
            @block = block
            @retries = 0
          end

          def to_h
            { body: body }
          end

          def to_s
            "#<#{self.class.name} key=#{key}, retries=#{retries}>"
          end

          def liquid?
            file.liquid?
          end

          def key
            file.relative_path
          end

          def size
            @size ||= body.bytesize
          end

          def body
            @body ||= JSON.generate(asset: asset)
          end

          def asset
            @asset ||= asset_hash
          end

          private

          def asset_hash
            asset = { key: file.relative_path }

            if file.text?
              asset[:value] = file.read
            else
              asset[:attachment] = Base64.encode64(file.read)
            end

            asset
          end
        end
      end
    end
  end
end
