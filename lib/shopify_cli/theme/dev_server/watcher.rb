# frozen_string_literal: true
require "listen"
require "observer"
require "thread"

module ShopifyCLI
  module Theme
    module DevServer
      # Watches for file changes and publish events to the theme
      class Watcher
        include Observable

        def initialize(ctx, theme:, syncer:, ignore_filter: nil, poll: false, pull_json_interval: nil)
          @ctx = ctx
          @theme = theme
          @syncer = syncer
          @ignore_filter = ignore_filter
          @listener = Listen.to(@theme.root, force_polling: poll) do |modified, added, removed|
            changed
            notify_observers(modified, added, removed)
          end
          @pull_json_interval = pull_json_interval

          add_observer(self, :upload_files_when_changed)
        end

        def start
          @listener.start

          if @pull_json_interval
            @pull_thread = Thread.new do
              loop do
                @syncer.fetch_checksums!
                @syncer.enqueue_get(@theme.json_files)
                sleep(@pull_json_interval)
              end
            end
          end
        end

        def stop
          if @pull_thread
            @pull_thread.kill
            @pull_thread.join
          end
          @listener.stop
        end

        def upload_files_when_changed(modified, added, removed)
          modified_theme_files = filter_theme_files(modified + added)
          if modified_theme_files.any?
            @syncer.enqueue_updates(modified_theme_files)
          end

          removed_theme_files = filter_remote_files(removed)
          if removed_theme_files.any?
            @syncer.enqueue_deletes(removed_theme_files)
          end
        end

        def filter_theme_files(files)
          files
            .select { |file| @theme.theme_file?(file) }
            .reject { |file| @ignore_filter&.ignore?(file) }
        end

        def filter_remote_files(files)
          files
            .select { |file| @syncer.remote_file?(file) }
            .reject { |file| @ignore_filter&.ignore?(file) }
        end
      end
    end
  end
end
