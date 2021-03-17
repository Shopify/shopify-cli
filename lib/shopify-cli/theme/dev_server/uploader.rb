# frozen_string_literal: true
require "thread"
require "json"
require "base64"

module ShopifyCli
  module Theme
    module DevServer
      class Uploader
        def initialize(theme)
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
          response = Net::HTTP.start(@theme.assets_api_uri.host, 443, use_ssl: true) do |http|
            req = Net::HTTP::Get.new(@theme.assets_api_uri)
            req["X-Shopify-Access-Token"] = @theme.config.password
            req["Accept"] = "application/json"
            req["Content-Type"] = "application/json"
            http.request(req)
          end

          @theme.update_checksums!(response)
        end

        def upload(file)
          if @theme.ignore?(file)
            puts "Ignoring #{file.relative_path}" if ThemeDevServer.debug
            return
          end

          if @theme.file_has_changed?(file)
            puts "Uploading #{file.relative_path} to #{@theme.assets_api_uri}" if ThemeDevServer.debug

            response = Net::HTTP.start(@theme.assets_api_uri.host, 443, use_ssl: true) do |http|
              req = Net::HTTP::Put.new(@theme.assets_api_uri)
              req["X-Shopify-Access-Token"] = @theme.config.password
              req["Accept"] = "application/json"
              req["Content-Type"] = "application/json"
              req.body = JSON.generate({
                asset: {
                  key: file.relative_path.to_s,
                  attachment: Base64.encode64(file.read),
                },
              })

              http.request(req)
            end

            @theme.update_checksums!(response)
          elsif ThemeDevServer.debug
            puts "#{file.relative_path} has not changed, skipping upload"
          end
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
