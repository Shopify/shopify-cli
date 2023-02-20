# frozen_string_literal: true

require "thread"
require "json"
require "base64"
require "forwardable"

require_relative "backoff_helper"
require_relative "ignore_helper"
require_relative "theme_admin_api"

require_relative "syncer/checksums"
require_relative "syncer/downloader"
require_relative "syncer/error_reporter"
require_relative "syncer/merger"
require_relative "syncer/operation"
require_relative "syncer/standard_reporter"
require_relative "syncer/unsupported_script_warning"
require_relative "syncer/uploader"

module ShopifyCLI
  module Theme
    class Syncer
      extend Forwardable

      include ShopifyCLI::Theme::IgnoreHelper
      include ShopifyCLI::Theme::BackoffHelper

      QUEUEABLE_METHODS = [
        :get,         # - Updates the local file with the remote file content
        :update,      # - Updates the remote file with the local file content
        :delete,      # - Deletes the remote file
        :union_merge, # - Union merges the local file content with the remote file content
      ]

      attr_reader :ctx, :theme, :checksums, :error_checksums, :api_client, :pending, :standard_reporter
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

        # Latest theme assets checksums. Updated on each upload.
        @checksums = Checksums.new(theme)

        # Checksums of assets with errors.
        @error_checksums = []

        # Do not use the throttler when --stable is passed or a Theme Access password is set
        # (Theme Access API is not compatible yet with bulks)
        @bulk_updates_activated = !stable && !Environment.theme_access_password?

        # Initialize `api_client` on main thread
        @api_client = ThemeAdminAPI.new(ctx, theme.shop)

        # Initialize backoff helper on main thread to pause all threads when the
        # requests are reaching API rate limits.
        initialize_backoff_helper!
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
          path: "themes/#{@theme.id}/assets.json",
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
            rescue Exception => e # rubocop:disable Lint/RescueException
              error_suffix = ": #{e}"
              error_suffix += + "\n\t#{e.backtrace.join("\n\t")}" if @ctx.debug?
              report_error(operation, error_suffix)
            end
          end
        end
      end

      def upload_theme!(delay_low_priority_files: false, delete: true, &block)
        uploader = Uploader.new(self, delete, delay_low_priority_files, &block)
        uploader.upload!
      end

      def download_theme!(delete: true, &block)
        downloader = Downloader.new(self, delete, &block)
        downloader.download!
      end

      def bulk_updates_activated?
        @bulk_updates_activated
      end

      def enqueueable?(operation)
        file = operation.file
        method = operation.method

        # Already enqueued or ignored
        return false if @pending.include?(operation) || ignore_operation?(operation)

        if [:update, :get].include?(method) && file.exist?
          # File is fixed (and it has been never updated)
          if !!@error_checksums.delete(file.checksum)
            @standard_reporter.report(operation.as_fix_message)
          end

          return checksums.file_has_changed?(file)
        end

        true
      end

      def handle_operation_error(operation, error)
        error_suffix = ":\n  " + parse_api_errors(operation.file, error).join("\n  ")
        report_error(operation, error_suffix)
      end

      def overwrite_json?
        theme_created_at_runtime? || @overwrite_json
      end

      def update_checksums(api_response)
        api_response.values.flatten.each do |asset|
          next unless asset["key"]

          checksums[asset["key"]] = asset["checksum"]
        end

        checksums.reject_duplicated_checksums!
      end

      def report_file_error(file, error_message = "")
        path = file.relative_path

        @error_checksums << checksums[path]
        @error_reporter.report(error_message)
      end

      def parse_api_errors(file, exception)
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
        ["The asset #{file} could not be synced #{cause} #{backtrace}"]
      end

      private

      def report_error(operation, error_suffix = "")
        file = operation.file
        error_message = "#{operation.as_error_message}#{error_suffix}"

        report_file_error(file, error_message)
      end

      def enqueue(method, file)
        raise ArgumentError, "file required" unless file
        raise ArgumentError, "method '#{method}' cannot be queued" unless QUEUEABLE_METHODS.include?(method)

        operation = Operation.new(@ctx, method, @theme[file])

        return unless enqueueable?(operation)

        @pending << operation
        @queue << operation unless @queue.closed?
      end

      def report_performed_operation(operation)
        file = operation.file

        if file.warnings.any?
          warning_message =
            operation.as_synced_message(color: :yellow) +
            UnsupportedScriptWarning.new(@ctx, file).to_s

          return @error_reporter.report(warning_message)
        end

        @standard_reporter.report(operation.as_synced_message)
      end

      def perform(operation)
        return if @queue.closed?

        wait_for_backoff!
        @ctx.debug(operation.to_s)

        response = send(operation.method, operation.file)

        report_performed_operation(operation)
        backoff_if_near_limit!(response)
      rescue StandardError => error
        handle_operation_error(operation, error)
      ensure
        @pending.delete(operation)
      end

      def update(file)
        asset = { key: file.relative_path }

        if file.text?
          asset[:value] = file.read
        else
          asset[:attachment] = Base64.encode64(file.read)
        end

        path = "themes/#{@theme.id}/assets.json"

        _status, body, response = api_client.put(
          path: path,
          body: JSON.generate(asset: asset),
        )
        file.warnings = body.dig("asset", "warnings")

        update_checksums(body)

        response
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

        response
      end

      def delete(file)
        _status, _body, response = api_client.delete(
          path: "themes/#{@theme.id}/assets.json",
          body: JSON.generate(asset: {
            key: file.relative_path,
          }),
        )

        checksums.delete(file) if checksums.has?(file)

        response
      end

      def union_merge(file)
        _status, body, response = api_client.get(
          path: "themes/#{@theme.id}/assets.json",
          query: URI.encode_www_form("asset[key]" => file.relative_path),
        )

        return response unless file.text?

        remote_content = body.dig("asset", "value")

        return response if remote_content.nil?

        content = Merger.union_merge(file, remote_content)

        file.write(content)

        enqueue(:update, file)

        response
      end

      def theme_created_at_runtime?
        @theme.created_at_runtime?
      end

      def wait(duration)
        sleep(duration)
      end
    end
  end
end
