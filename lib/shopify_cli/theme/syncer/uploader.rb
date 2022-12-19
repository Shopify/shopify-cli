# frozen_string_literal: true

require "forwardable"

require_relative "uploader/bulk_item"
require_relative "uploader/bulk"
require_relative "uploader/json_delete_handler"
require_relative "uploader/json_update_handler"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        extend Forwardable

        include JsonDeleteHandler
        include JsonUpdateHandler

        attr_reader :syncer

        def_delegators :syncer,
          # helpers
          :ctx,
          :api_client,
          :theme,
          :ignore_file?,
          :overwrite_json?,
          :bulk_updates_activated?,
          # enqueue
          :enqueue_deletes,
          :enqueue_get,
          :enqueue_union_merges,
          :enqueue_updates,
          # checksums
          :checksums,
          :update_checksums,
          :fetch_checksums!,
          :wait!

        def initialize(syncer, delete, delay_low_priority_files, &update_progress_bar_block)
          @syncer = syncer
          @delete = delete
          @delay_low_priority_files = delay_low_priority_files
          @update_progress_bar_block = update_progress_bar_block
          @progress_bar_mutex = Mutex.new
        end

        def upload!
          fetch_checksums!
          delete_files!

          if bulk_updates_activated? && overwrite_json?
            bulk_upload!
          else
            async_upload!
          end
        end

        def delete_files!
          return unless delete?

          files_present_remotely = checksums.keys
          files_present_locally = theme.theme_files.map(&:relative_path)

          json_files, other_files = (files_present_remotely - files_present_locally)
            .map { |file| theme[file] }
            .reject { |file| ignore_file?(file) }
            .partition(&:json?)

          enqueue_deletes(other_files)
          enqueue_json_deletes(json_files)
        end

        private

        def bulk_upload!
          update_progress_bar!

          enqueue_bulk_updates(liquid_files)
          enqueue_bulk_updates(json_files)
          enqueue_bulk_updates(config_files)

          if delay_low_priority_files?
            # Process lower-priority files (assets) in the background, as they
            # are served locally
            enqueue_updates(static_asset_files)
          else
            enqueue_bulk_updates(static_asset_files)
          end

          wait!(&@update_progress_bar_block) unless delay_low_priority_files?
        end

        def async_upload!
          enqueue_updates(liquid_files)
          enqueue_json_updates(json_files)
          enqueue_updates(config_files)

          # Wait upload of Liquid & JSON files, as they are rendered remotely
          wait!(&@update_progress_bar_block) if delay_low_priority_files?

          # Process lower-priority files (assets) in the background, as they
          # are served locally
          enqueue_updates(static_asset_files)

          wait!(&@update_progress_bar_block) unless delay_low_priority_files?
        end

        def enqueue_bulk_updates(files)
          retries = 0
          pending_items = files.map { |file| bulk_item(file) }

          while pending_items.any? && retries < 2
            bulk = Bulk.new(ctx, theme, api_client)

            files
              .map { |file| bulk_item(file) }
              .each { |request| bulk.enqueue(request) }

            bulk.shutdown

            retries += 1
            pending_items = bulk.remaining_items
          end

          return unless pending_items.any?

          # Remaining items are handled in the background when the bulk timeout
          # is exceeded
          pending_items.size.times { update_progress_bar! }

          syncer.enqueue_updates(pending_items.map(&:file))
          syncer.wait!
        end

        def bulk_item(file)
          BulkItem.new(file) do |_s, body, response|
            if response.is_a?(StandardError)
              report(file, response)
            else
              update_checksums(body)
            end
          ensure
            update_progress_bar!
          end
        end

        def delete?
          @delete
        end

        def delay_low_priority_files?
          @delay_low_priority_files
        end

        # Files

        def number_of_bulk_items
          @number_of_files ||= [
            json_files.size,
            liquid_files.size,
            config_files.size,
            delay_low_priority_files? ? 0 : static_asset_files.size,
          ].reduce(:+)
        end

        def json_files
          @json_files ||= uploadable(theme.json_files) - config_files
        end

        def liquid_files
          @liquid_files ||= uploadable(theme.liquid_files)
        end

        def static_asset_files
          @static_asset_files ||= uploadable(theme.static_asset_files)
        end

        def config_files
          @config_files ||= uploadable(
            [
              theme["config/settings_schema.json"],
              theme["config/settings_data.json"],
            ],
          )
        end

        def uploadable(files)
          files.select { |file| uploadable?(file) }
        end

        def uploadable?(file)
          return false unless file.exist?
          return false if ignore_file?(file)

          checksums.file_has_changed?(file)
        end

        # Handle prorgress bar

        def update_progress_bar!
          @pending_files ||= number_of_bulk_items
          @pending_files -= 1

          # Avoid abrupt updates in the progress bar
          @progress_bar_mutex.synchronize do
            sleep(0.02)
            update_progress_bar(@pending_files, number_of_bulk_items)
          end
        end

        def update_progress_bar(size, total)
          @update_progress_bar_block&.call(size, total)
        end

        # Handler errors

        def report(file, error)
          file_path = file.relative_path

          error_message = syncer
            .parse_api_errors(file, error)
            .map { |msg| "#{file_path}: #{msg}" }
            .join("\n")

          syncer.report_file_error(file, error_message)
        end
      end
    end
  end
end
