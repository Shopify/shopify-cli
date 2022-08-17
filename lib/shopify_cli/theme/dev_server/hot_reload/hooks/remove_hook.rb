# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class HotReload
        class RemoveHook < Hook
          def initialize(ctx, theme:, ignore_filter: nil)
            @ignore_filter = ignore_filter
            @theme = theme
            @ctx = ctx
          end

          def call(_modified, _added, removed, streams: nil)
            @streams = streams
            deleted_files = removed
              .reject { |f| @ignore_filter&.ignore?(f) }
              .map { |f| @theme[f] }

            remote_delete(deleted_files) unless deleted_files.empty?
            reload_page(removed) unless deleted_files.empty?
          end

          private

          def remote_delete(files)
            files.each do |file|
              @ctx.debug("delete file each -> file.relative_path #{file.relative_path}")
              remote_file_deleter.delete(file)
            end
          end

          def reload_page(removed)
            @streams.broadcast(JSON.generate(reload_page: true))
            @ctx.debug("[ReloadPage] Deleted #{removed.join(", ")}")
          end

          def remote_file_deleter
            @remote_file_deleter ||= RemoteFileDeleter.new(@ctx, theme: @theme, streams: @streams)
          end
        end
      end
    end
  end
end
