# frozen_string_literal: true

require "shopify_cli/file_system_listener"
require "shopify_cli/theme/dev_server"
require "forwardable"

module ShopifyCLI
  module Theme
    module Extension
      class DevServer < ShopifyCLI::Theme::DevServer
        # Watches for file changes and publish events to the theme
        class Watcher
          extend Forwardable

          def_delegators :@listener, :add_observer, :changed, :notify_observers

          def initialize(ctx, extension:, syncer:, poll: false)
            @ctx = ctx
            @extension = extension
            @syncer = syncer
            @listener = FileSystemListener.new(root: @extension.root.to_s, force_poll: poll, ignore_regex: nil)

            add_observer(self, :notify_updates)
          end

          def start
            @listener.start
          end

          def stop
            @listener.stop
          end

          def notify_updates(modified, added, removed)
            @syncer.enqueue_updates(files(modified).select { |file| @extension.extension_file?(file) })
            @syncer.enqueue_creates(files(added).select { |file| @extension.extension_file?(file) })
            @syncer.enqueue_deletes(files(removed))
          end

          def files(paths)
            paths.map { |file| @extension[file] }
          end
        end
      end
    end
  end
end
