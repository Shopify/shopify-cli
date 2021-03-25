# frozen_string_literal: true
require "thread"
require "json"
require "base64"

module ShopifyCli
  module Theme
    module DevServer
      class Uploader
        def initialize(ctx, theme)
          @ctx = ctx
          @theme = theme
          @queue = Queue.new
          @threads = []
        end

        def enqueue_upload(file)
          file = @theme[file]
          @theme.pending_files << file
          @queue << file
        end

        def enqueue_uploads(files)
          files.each { |file| enqueue_upload(file) }
        end

        def wait_for_uploads!
          Thread.pass until @queue.empty?
        end

        def fetch_checksums!
          response = ShopifyCli::AdminAPI.rest_request(
            @ctx,
            shop: @theme.config.store,
            path: "themes/#{@theme.id}/assets.json",
            api_version: "unstable",
          )

          @theme.update_checksums!(response[1])
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

          @ctx.debug("Uploading #{file.relative_path} to #{@theme.assets_api_uri}")

          response = ShopifyCli::AdminAPI.rest_request(
            @ctx,
            shop: @theme.config.store,
            path: "themes/#{@theme.id}/assets.json",
            method: "PUT",
            api_version: "unstable",
            body: JSON.generate({
              asset: {
                key: file.relative_path.to_s,
                attachment: Base64.encode64(file.read),
              },
            })
          )

          @theme.update_checksums!(response[1])
        rescue ShopifyCli::API::APIRequestError => e
          @ctx.abort("Could not upload theme asset: #{e.message}")
        ensure
          @theme.pending_files.delete(file)
        end

        def shutdown
          @queue.close unless @queue.closed?
        ensure
          @threads.each { |thread| thread.join if thread.alive? }
        end

        def start_threads(count = 10)
          count.times do
            @threads << Thread.new do
              loop do
                file = @queue.pop
                break if file.nil? # shutdown was called
                upload(file)
              rescue => e
                puts "Error while uploading '#{file&.relative_path}': #{e}"
              end
            end
          end
        end
      end
    end
  end
end
