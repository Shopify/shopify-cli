# frozen_string_literal: true
require "thread"
require "json"
require "base64"
require "benchmark"

module ShopifyCli
  module Theme
    module DevServer
      class Uploader
        def initialize(ctx, theme)
          @ctx = ctx
          @theme = theme
          @queue = Queue.new
          @threads = []
          @backoff_mutex = Mutex.new
        end

        def enqueue_upload(file)
          file = @theme[file]
          return if @theme.pending_files.include?(file) || @theme.ignore?(file)
          @theme.pending_files << file
          @queue << file unless @queue.closed?
        end

        def enqueue_uploads(files)
          files.each { |file| enqueue_upload(file) }
        end

        def size
          @theme.pending_files.size
        end

        def empty?
          @theme.pending_files.empty?
        end

        def wait_for_uploads!
          total = size
          last_size = size
          until empty? || @queue.closed?
            if block_given? && last_size != size
              yield size, total
              last_size = size
            end
            Thread.pass
          end
        end

        def fetch_remote_checksums!
          response = ShopifyCli::AdminAPI.rest_request(
            @ctx,
            shop: @theme.shop,
            path: "themes/#{@theme.id}/assets.json",
            api_version: "unstable",
          )

          @theme.update_remote_checksums!(response[1])
        rescue ShopifyCli::API::APIRequestError => e
          @ctx.abort("Could not fetch checksums for theme assets: #{e.message}")
        end

        def upload(file)
          if @theme.ignore?(file)
            @ctx.debug("Ignoring #{file.relative_path}")
            return
          end

          unless @theme.file_has_changed?(file)
            @ctx.debug("#{file.relative_path} has not changed, skipping upload")
            return
          end

          return if @queue.closed?
          wait_for_backoff!
          @ctx.debug("Uploading #{file.relative_path}")

          asset = { key: file.relative_path.to_s }
          if file.text?
            asset[:value] = file.read
          else
            asset[:attachment] = Base64.encode64(file.read)
          end

          _status, body, headers = ShopifyCli::AdminAPI.rest_request(
            @ctx,
            shop: @theme.shop,
            path: "themes/#{@theme.id}/assets.json",
            method: "PUT",
            api_version: "unstable",
            body: JSON.generate(asset: asset)
          )

          # Check if the API told us we're near the rate limit
          if !backingoff? && (limit = headers["x-shopify-shop-api-call-limit"])
            used, total = limit.split("/").map(&:to_i)
            backoff_if_near_limit!(used, total)
          end

          @theme.update_remote_checksums!(body)
        rescue ShopifyCli::API::APIRequestError => e
          @ctx.message("Could not upload theme asset: #{e.message}")
        ensure
          @theme.pending_files.delete(file)
        end

        def shutdown
          @queue.close unless @queue.closed?
        ensure
          @threads.each { |thread| thread.join if thread.alive? }
        end

        def start_threads(count = 2)
          count.times do
            @threads << Thread.new do
              loop do
                file = @queue.pop
                break if file.nil? # shutdown was called
                upload(file)
              rescue => e
                @ctx.puts("{{red:ERROR}} while uploading '#{file&.relative_path}': #{e}")
                @ctx.debug("\t#{e.backtrace.join("\n\t")}")
              end
            end
          end
        end

        def upload_theme!(&block)
          fetch_remote_checksums!

          enqueue_uploads(@theme.liquid_files)
          enqueue_uploads(@theme.json_files)

          # Wait for liquid & JSON files to upload, because those are rendered remotely
          time = Benchmark.realtime do
            wait_for_uploads!(&block)
          end
          @ctx.debug("Theme uploaded in #{time} seconds")

          # Assets are served locally, so can be uploaded in the background
          enqueue_uploads(@theme.assets)
        end

        private

        def backoff_if_near_limit!(used, limit)
          if used > limit - @threads.size
            @ctx.debug("Near API call limit, waiting 2 sec ...")
            @backoff_mutex.synchronize { sleep 2 }
          end
        end

        def backingoff?
          @backoff_mutex.locked?
        end

        def wait_for_backoff!
          # Sleeping in the mutex in another thread. Wait for unlock
          @backoff_mutex.synchronize {} if backingoff?
        end
      end
    end
  end
end
