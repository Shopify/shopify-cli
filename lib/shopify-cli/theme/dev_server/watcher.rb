# frozen_string_literal: true
require "listen"
require "observer"

module ShopifyCli
  module Theme
    module DevServer
      # Watches for file changes and publish events to the theme
      class Watcher
        include Observable

        def initialize(theme)
          @theme = theme
          @uploader = Uploader.new(theme)
          @listener = Listen.to(@theme.root) do |modified, added, removed|
            changed
            notify_observers(modified, added, removed)
          end

          add_observer(self, :upload_files_when_changed)
        end

        def start
          @uploader.start_threads
          upload_theme!
          @listener.start
        end

        def stop
          @uploader.shutdown
          @listener.stop
        end

        def upload_files_when_changed(modified, added, _removed)
          modified_theme_files = (modified + added)
            .select { |file| @theme.theme_file?(file) }
            .reject { |file| @theme.ignore?(file) }
          if modified_theme_files.any?
            @uploader.enqueue_uploads(modified_theme_files)
          end
          # TODO: how to deal w/ removed files?
        end

        private

        def upload_theme!
          @uploader.fetch_checksums!
          @uploader.enqueue_uploads(@theme.theme_files)
          @uploader.wait_for_uploads!
        end
      end
    end
  end
end
