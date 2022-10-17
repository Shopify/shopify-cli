# frozen_string_literal: true

require "forwardable"

module ShopifyCLI
  module Theme
    class Syncer
      class Downloader
        extend Forwardable

        attr_reader :syncer, :ctx

        def_delegators :syncer,
          :ctx,
          :checksums,
          :enqueue_get,
          :ignore_file?,
          :fetch_checksums!,
          :wait!

        def initialize(syncer, delete, &update_progress_bar_block)
          @syncer = syncer
          @delete = delete
          @update_progress_bar_block = update_progress_bar_block
        end

        def download!
          fetch_checksums!

          if delete_local_files?
            to_be_deleted.each { |file| delete(file) }
          end

          enqueue_get(checksums.keys)
          wait!(&@update_progress_bar_block)
        end

        private

        def delete(file)
          ctx.debug("[#{self.class}] rm #{file.relative_path}")
          file.delete
        end

        def delete_local_files?
          @delete
        end

        def to_be_deleted
          @to_be_deleted ||= syncer
            .theme
            .theme_files
            .reject { |file| present_remotely?(file) }.uniq
            .reject { |file| ignore_file?(file) }
        end

        def present_remotely?(file)
          checksums.has?(file)
        end
      end
    end
  end
end
