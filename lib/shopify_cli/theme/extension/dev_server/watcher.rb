# frozen_string_literal: true
require "shopify_cli/file_system_listener"
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

          def notify_updates(modified, added, _removed)
            @syncer.enqueue_files(filter_extension_files(modified + added))
          end

          private

          def filter_extension_files(files)
            files
              .select { |f| @extension.extension_file?(f) }
              .map { |f| @extension[f] }
          end
        end
      end
    end
  end
end
