# frozen_string_literal: true
require "thread"
require "json"
require "base64"
require "forwardable"

require_relative "syncer/error_reporter"
require_relative "syncer/standard_reporter"
require_relative "syncer/operation"

module ShopifyCLI
  module Theme
    class Syncer
      extend Forwardable

      API_VERSION = "unstable"

      attr_reader :checksums
      attr_accessor :include_filter
      attr_accessor :ignore_filter

      def_delegators :@error_reporter, :has_any_error?

      def initialize(ctx, theme:, include_filter: nil, ignore_filter: nil)
        @ctx = ctx
        @theme = theme
        @include_filter = include_filter
        @ignore_filter = ignore_filter
        @error_reporter = ErrorReporter.new(ctx)
        @standard_reporter = StandardReporter.new(ctx)
        @reporters = [@error_reporter, @standard_reporter]

        # Queue of `Operation`s waiting to be picked up from a thread for processing.
        @queue = Queue.new
        # `Operation`s will be removed from this Array completed.
        @pending = []
        # Thread making the API requests.
        @threads = []
        # Mutex used to pause all threads when backing-off when hitting API rate limits
        @backoff_mutex = Mutex.new

        # Latest theme assets checksums. Updated on each upload.
        @checksums = {}

        # Checksums of assets with errors.
        @error_checksums = []
      end

      def lock_io!
        @reporters.each(&:disable!)
      end

      def unlock_io!
        @reporters.each(&:enable!)
      end

      def enqueue_updates(files)
        files.each { |file| enqueue(:update, file) }
      end

      def enqueue_get(files)
        files.each { |file| enqueue(:get, file) }
      end

      def enqueue_deletes(files)
        files.each { |file| enqueue(:delete, file) }
      end

      def size
        @pending.size
      end

      def empty?
        @pending.empty?
      end

      def pending_updates
        @pending.select { |op| op.method == :update }.map(&:file)
      end

      def remote_file?(file)
        checksums.key?(@theme[file].relative_path.to_s)
      end

      def wait!
        raise ThreadError, "No syncer threads" if @threads.empty?
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

      def fetch_checksums!
        _status, response = ShopifyCLI::AdminAPI.rest_request(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          api_version: API_VERSION,
        )
        update_checksums(response)
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
              operation = @queue.pop
              break if operation.nil? # shutdown was called
              perform(operation)
            rescue => e
              error_suffix = ": #{e}"
              error_suffix += + "\n\t#{e.backtrace.join("\n\t")}" if @ctx.debug?
              report_error(operation, error_suffix)
            end
          end
        end
      end

      def upload_theme!(delay_low_priority_files: false, delete: true, &block)
        fetch_checksums!

        if delete
          # Delete remote files not present locally
          removed_files = checksums.keys - @theme.theme_files.map { |file| file.relative_path.to_s }
          enqueue_deletes(removed_files)
        end

        # Some files must be uploaded after the other ones
        delayed_config_files = [
          @theme["config/settings_schema.json"],
          @theme["config/settings_data.json"],
        ]

        enqueue_updates(@theme.liquid_files)
        enqueue_updates(@theme.json_files - delayed_config_files)
        enqueue_updates(delayed_config_files)

        if delay_low_priority_files
          # Wait for liquid & JSON files to upload, because those are rendered remotely
          wait!(&block)
        end

        # Process lower-priority files in the background

        # Assets are served locally, so can be uploaded in the background
        enqueue_updates(@theme.static_asset_files)

        unless delay_low_priority_files
          wait!(&block)
        end
      end

      def download_theme!(delete: true, &block)
        fetch_checksums!

        if delete
          # Delete local files not present remotely
          missing_files = @theme.theme_files
            .reject { |file| checksums.key?(file.relative_path.to_s) }.uniq
            .reject { |file| @ignore_filter&.ignore?(file) }
          missing_files.each do |file|
            @ctx.debug("rm #{file.relative_path}")
            file.delete
          end
        end

        enqueue_get(checksums.keys)

        wait!(&block)
      end

      private

      def report_error(operation, error_suffix = "")
        @error_checksums << @checksums[operation.file_path]
        @error_reporter.report("#{operation.as_error_message}#{error_suffix}")
      end

      def enqueue(method, file)
        raise ArgumentError, "file required" unless file

        operation = Operation.new(@ctx, method, @theme[file])

        # Already enqueued
        return if @pending.include?(operation)

        if ignore?(operation)
          @ctx.debug("ignore #{operation.file_path}")
          return
        end

        if [:update, :get].include?(method) && operation.file.exist? && !file_has_changed?(operation.file)
          is_fixed = !!@error_checksums.delete(operation.file.checksum)
          @standard_reporter.report(operation.as_fix_message) if is_fixed
          return
        end

        @pending << operation
        @queue << operation unless @queue.closed?
      end

      def perform(operation)
        return if @queue.closed?
        wait_for_backoff!
        @ctx.debug(operation.to_s)

        response = send(operation.method, operation.file)

        @standard_reporter.report(operation.as_synced_message)

        # Check if the API told us we're near the rate limit
        if !backingoff? && (limit = response["x-shopify-shop-api-call-limit"])
          used, total = limit.split("/").map(&:to_i)
          backoff_if_near_limit!(used, total)
        end
      rescue ShopifyCLI::API::APIRequestError => e
        error_suffix = ":\n  " + parse_api_errors(e).join("\n  ")
        report_error(operation, error_suffix)
      ensure
        @pending.delete(operation)
      end

      def update(file)
        asset = { key: file.relative_path.to_s }
        if file.text?
          asset[:value] = file.read
        else
          asset[:attachment] = Base64.encode64(file.read)
        end

        _status, body, response = ShopifyCLI::AdminAPI.rest_request(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          method: "PUT",
          api_version: API_VERSION,
          body: JSON.generate(asset: asset)
        )

        update_checksums(body)

        response
      end

      def ignore?(operation)
        path = operation.file_path
        ignored_by_ignore_filter?(path) || ignored_by_include_filter?(path)
      end

      def ignored_by_ignore_filter?(path)
        ignore_filter&.ignore?(path)
      end

      def ignored_by_include_filter?(path)
        include_filter && !include_filter.match?(path)
      end

      def get(file)
        _status, body, response = ShopifyCLI::AdminAPI.rest_request(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          method: "GET",
          api_version: API_VERSION,
          query: URI.encode_www_form("asset[key]" => file.relative_path.to_s),
        )

        update_checksums(body)

        attachment = body.dig("asset", "attachment")
        if attachment
          file.write(Base64.decode64(attachment))
        else
          file.write(body.dig("asset", "value"))
        end

        response
      end

      def delete(file)
        _status, _body, response = ShopifyCLI::AdminAPI.rest_request(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          method: "DELETE",
          api_version: API_VERSION,
          body: JSON.generate(asset: {
            key: file.relative_path.to_s,
          })
        )

        response
      end

      def update_checksums(api_response)
        api_response.values.flatten.each do |asset|
          if asset["key"]
            @checksums[asset["key"]] = asset["checksum"]
          end
        end
        # Generate .liquid asset files are reported twice in checksum:
        # once of generated, once for .liquid. We only keep the .liquid, that's the one we have
        # on disk.
        @checksums.reject! { |key, _| @checksums.key?("#{key}.liquid") }
      end

      def file_has_changed?(file)
        file.checksum != @checksums[file.relative_path.to_s]
      end

      def parse_api_errors(exception)
        parsed_body = JSON.parse(exception&.response&.body)
        message = parsed_body.dig("errors", "asset") || parsed_body["message"] || exception.message
        # Truncate to first lines
        [message].flatten.map { |mess| mess.split("\n", 2).first }
      rescue JSON::ParserError
        [exception.message]
      end

      def backoff_if_near_limit!(used, limit)
        if used > limit - @threads.size
          @ctx.debug("Near API call limit, waiting 2 sec…")
          @backoff_mutex.synchronize { sleep(2) }
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
