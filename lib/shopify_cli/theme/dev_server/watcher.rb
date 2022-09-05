# frozen_string_literal: true
require "shopify_cli/file_system_listener"
require "forwardable"

module ShopifyCLI
  module Theme
    class DevServer
      # Watches for file changes and publish events to the theme
      class Watcher
        extend Forwardable

        def_delegators :@listener, :add_observer, :changed, :notify_observers

        def initialize(ctx, theme:, syncer:, ignore_filter: nil, poll: false)
          @ctx = ctx
          @theme = theme
          @syncer = syncer
          @ignore_filter = ignore_filter
          @listener = FileSystemListener.new(root: @theme.root, force_poll: poll,
            ignore_regex: @ignore_filter&.regexes)

          add_observer(self, :upload_files_when_changed)
        end

        def start
          @listener.start
        end

        def stop
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
            .map { |file| @theme[file] }
            .reject { |file| @syncer.ignore_file?(file) }
        end

        def filter_remote_files(files)
          files
            .select { |file| @syncer.remote_file?(file) }
            .map { |file| @theme[file] }
            .reject { |file| @syncer.ignore_file?(file) }
        end
      end
    end
  end
end
