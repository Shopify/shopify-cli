# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module Extension
      class DevServer
        module Hooks
          class FileChangeHook
            attr_reader :ctx, :extension, :syncer, :streams

            def initialize(ctx, extension:, syncer:)
              @ctx = ctx
              @extension = extension
              @syncer = syncer
            end

            def call(modified, added, removed, streams: nil)
              @streams = streams

              modified = paths(modified).select { |file| @extension.extension_file?(file) }
              added = paths(added).select { |file| @extension.extension_file?(file) }
              removed = paths(removed)

              hot_reload(modified) unless modified.empty?
              reload_page(added, removed) unless (added + removed).empty?
            end

            private

            def hot_reload(modified)
              broadcast(modified: modified)

              ctx.debug("[HotReload] Modified: #{modified.join(", ")}")
            end

            def reload_page(added, removed)
              wait_blocking_operations

              broadcast(reload_page: true)

              ctx.debug("[ReloadPage] Added: #{added.join(", ")}")
              ctx.debug("[ReloadPage] Removed: #{removed.join(", ")}")
            end

            def wait_blocking_operations
              retries = 10
              while syncer.any_blocking_operation? && !retries.zero?
                sleep(0.5)
                retries -= 1
              end
            end

            def paths(files)
              files
                .map { |file| extension[file] }
                .reject(&:liquid_css?)
                .map(&:relative_path)
            end

            def broadcast(message)
              streams&.broadcast(JSON.generate(message))
            end
          end
        end
      end
    end
  end
end
