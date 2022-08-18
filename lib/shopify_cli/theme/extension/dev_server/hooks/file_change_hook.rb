# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module Extension
      class DevServer
        module Hooks
          class FileChangeHook
            def initialize(ctx, extension:)
              @ctx = ctx
              @extension = extension
            end

            def call(modified, added, removed, streams: nil)
              @streams = streams
              files = (modified + added)
                .map { |f| @extension[f] }
                .reject(&:liquid_css?)
              deleted_files = removed
                .map { |f| @extension[f] }

              reload_page(removed) unless deleted_files.empty?
              hot_reload(files) unless files.empty?
            end

            private

            def hot_reload(files)
              paths = files.map(&:relative_path)
              @streams.broadcast(JSON.generate(modified: paths))
              @ctx.debug("[HotReload] Modified #{paths.join(", ")}")
            end

            def reload_page(removed)
              @streams.broadcast(JSON.generate(reload_page: true))
              @ctx.debug("[ReloadPage] Deleted #{removed.join(", ")}")
            end
          end
        end
      end
    end
  end
end
