# frozen_string_literal: true

require "thread"
require "json"
require "base64"
require "forwardable"

require_relative "syncer/checksums"
require_relative "syncer/error_reporter"
require_relative "syncer/json_delete_handler"
require_relative "syncer/json_update_handler"
require_relative "syncer/merger"
require_relative "syncer/operation"
require_relative "syncer/standard_reporter"
require_relative "syncer/unsupported_script_warning"
require_relative "theme_admin_api"
require_relative "ignore_helper"
require_relative "theme_admin_api_throttler"

module ShopifyCLI
  module Theme
    class Syncer
      extend Forwardable

      include ShopifyCLI::Theme::IgnoreHelper
      include JsonDeleteHandler
      include JsonUpdateHandler

      QUEUEABLE_METHODS = [
        :get,         # - Updates the local file with the remote file content
        :update,      # - Updates the remote file with the local file content
        :delete,      # - Deletes the remote file
        :union_merge, # - Union merges the local file content with the remote file content
      ]

      attr_reader :theme, :checksums, :error_checksums, :api_client
      attr_accessor :include_filter, :ignore_filter

      def_delegators :@error_reporter, :has_any_error?

      def initialize(ctx, theme:, include_filter: nil, ignore_filter: nil, overwrite_json: true, stable: false)
        @ctx = ctx
        @theme = theme
        @include_filter = include_filter
        @ignore_filter = ignore_filter
        @overwrite_json = overwrite_json
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

        # Mutex used to coordinate changes in the `pending` list
        @pending_mutex = Mutex.new

        # Latest theme assets checksums. Updated on each upload.
        @checksums = Checksums.new(theme)

        # Checksums of assets with errors.
        @error_checksums = []

        # Do not use the throttler when --stable is passed or a Theme Access password is set
        # (Theme Access API is not compatible yet with bulks)
        active_throttler = !stable && !Environment.theme_access_password?

        # Initialize `api_client` on main thread
        @api_client = ThemeAdminAPIThrottler.new(
          @ctx,
          ThemeAdminAPI.new(@ctx, @theme.shop),
          active_throttler
        )
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

      def enqueue_union_merges(files)
        files.each { |file| enqueue(:union_merge, file) }
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
        checksums.has?(file)
      end

      def broken_file?(file)
        error_checksums.include?(checksums[file.relative_path])
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
        _status, response = api_client.get(
          path: "themes/#{@theme.id}/assets.json"
        )
        update_checksums(response)
      end

      def shutdown
        api_client.shutdown
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
            rescue Exception => e # rubocop:disable Lint/RescueException
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
          removed_json_files, removed_files = checksums
            .keys
            .-(@theme.theme_files.map(&:relative_path))
            .map { |file| @theme[file] }
            .partition(&:json?)

          enqueue_deletes(removed_files)
          enqueue_json_deletes(removed_json_files)
        end

        enqueue_updates(@theme.liquid_files)
        enqueue_json_updates(@theme.json_files)

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

        api_client.deactivate_throttler!
        enqueue_delayed_files_updates
      end

      def download_theme!(delete: true, &block)
        fetch_checksums!

        if delete
          # Delete local files not present remotely
          missing_files = @theme.theme_files
            .reject { |file| checksums.has?(file) }.uniq
            .reject { |file| ignore_file?(file) }
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
        @error_checksums << checksums[operation.file_path]
        @error_reporter.report("#{operation.as_error_message}#{error_suffix}")
      end

      def enqueue(method, file)
        raise ArgumentError, "file required" unless file
        raise ArgumentError, "method '#{method}' cannot be queued" unless QUEUEABLE_METHODS.include?(method)

        operation = Operation.new(@ctx, method, @theme[file])

        # Already enqueued
        return if @pending.include?(operation)

        if ignore_operation?(operation)
          @ctx.debug("ignore #{operation.file_path}")
          return
        end

        if [:update, :get].include?(method) && operation.file.exist?
          is_fixed = !!@error_checksums.delete(operation.file.checksum)
          @standard_reporter.report(operation.as_fix_message) if is_fixed
          return unless checksums.file_has_changed?(operation.file)
        end

        @pending << operation
        @queue << operation unless @queue.closed?
      end

      def perform(operation)
        return if @queue.closed?
        wait_for_backoff!
        @ctx.debug(operation.to_s)

        send(operation.method, operation.file) do |response|
          raise response if response.is_a?(StandardError)

          file = operation.file

          if file.warnings.any?
            warning_message =
              operation.as_synced_message(color: :yellow) +
              UnsupportedScriptWarning.new(@ctx, file).to_s
            @error_reporter.report(warning_message)
          else
            @standard_reporter.report(operation.as_synced_message)
          end

          # Check if the API told us we're near the rate limit
          if !backingoff? && (limit = response["x-shopify-shop-api-call-limit"])
            used, total = limit.split("/").map(&:to_i)
            backoff_if_near_limit!(used, total)
          end
        rescue StandardError => error
          handle_operation_error(operation, error)
        ensure
          @pending_mutex.synchronize do
            # Avoid abrupt jumps in the progress bar
            wait(0.05)
            @pending.delete(operation)
          end
        end
      rescue StandardError => error
        handle_operation_error(operation, error)
      end

      def update(file)
        asset = { key: file.relative_path }

        if file.text?
          asset[:value] = file.read
        else
          asset[:attachment] = Base64.encode64(file.read)
        end

        path = "themes/#{@theme.id}/assets.json"
        req_body = JSON.generate(asset: asset)

        api_client.put(path: path, body: req_body) do |_status, resp_body, response|
          update_checksums(resp_body)

          file.warnings = resp_body.dig("asset", "warnings")

          yield(response) if block_given?
        end
      end

      def get(file)
        _status, body, response = api_client.get(
          path: "themes/#{@theme.id}/assets.json",
          query: URI.encode_www_form("asset[key]" => file.relative_path),
        )

        update_checksums(body)

        attachment = body.dig("asset", "attachment")
        if attachment
          file.write(Base64.decode64(attachment))
        else
          file.write(body.dig("asset", "value"))
        end

        yield(response)
      end

      def delete(file)
        _status, _body, response = api_client.delete(
          path: "themes/#{@theme.id}/assets.json",
          body: JSON.generate(asset: {
            key: file.relative_path,
          })
        )

        yield(response)
      end

      def union_merge(file)
        _status, body, response = api_client.get(
          path: "themes/#{@theme.id}/assets.json",
          query: URI.encode_www_form("asset[key]" => file.relative_path),
        )

        return yield(response) unless file.text?

        remote_content = body.dig("asset", "value")

        return yield(response) if remote_content.nil?

        content = Merger.union_merge(file, remote_content)

        file.write(content)

        enqueue(:update, file)

        yield(response)
      end

      def update_checksums(api_response)
        api_response.values.flatten.each do |asset|
          next unless asset["key"]
          checksums[asset["key"]] = asset["checksum"]
        end

        checksums.reject_duplicated_checksums!
      end

      def parse_api_errors(operation, exception)
        parsed_body = {}

        if exception.respond_to?(:response)
          response = exception.response

          parsed_body = if response&.is_a?(Hash)
            response&.[](:body)
          else
            JSON.parse(response&.body)
          end
        end

        errors = parsed_body.dig("errors") # either nil or another type
        errors = errors.dig("asset") if errors&.is_a?(Hash)

        message = errors || parsed_body["message"] || exception.message
        # Truncate to first lines
        [message].flatten.map { |m| m.split("\n", 2).first }
      rescue JSON::ParserError
        [exception.message]
      rescue StandardError => e
        cause = "(cause: #{e.message})"
        backtrace = e.backtrace.join("\n")
        ["The asset #{operation.file} could not be synced #{cause} #{backtrace}"]
      end

      def backoff_if_near_limit!(used, limit)
        if used > limit - @threads.size
          @ctx.debug("Near API call limit, waiting 2 sec…")
          @backoff_mutex.synchronize { wait(2) }
        end
      end

      def overwrite_json?
        theme_created_at_runtime? || @overwrite_json
      end

      def theme_created_at_runtime?
        @theme.created_at_runtime?
      end

      def backingoff?
        @backoff_mutex.locked?
      end

      def wait_for_backoff!
        # Sleeping in the mutex in another thread. Wait for unlock
        @backoff_mutex.synchronize {} if backingoff?
      end

      def handle_operation_error(operation, error)
        error_suffix = ":\n  " + parse_api_errors(operation, error).join("\n  ")
        report_error(operation, error_suffix)
      end

      def wait(duration)
        sleep(duration)
      end
    end
  end
end
