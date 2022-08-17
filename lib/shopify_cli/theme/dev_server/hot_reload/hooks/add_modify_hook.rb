# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class HotReload
        class AddModifyHook < Hook
          def initialize(ctx, theme:, ignore_filter: nil)
            @ctx = ctx
            @theme = theme
            @ignore_filter = ignore_filter
          end

          def call(modified, added, _removed, streams: nil)
            @streams = streams
            files = (modified + added)
              .reject { |f| @ignore_filter&.ignore?(f) }
              .map { |f| @theme[f] }
            files -= liquid_css_files = files.select(&:liquid_css?)

            hot_reload(files) unless files.empty?
            remote_reload(liquid_css_files)
          end

          private

          def hot_reload(files)
            paths = files.map(&:relative_path)
            @streams.broadcast(JSON.generate(modified: paths))
            @ctx.debug("[HotReload] Modified #{paths.join(", ")}")
          end

          def remote_reload(files)
            files.each do |file|
              @ctx.debug("reload file each -> file.relative_path #{file.relative_path}")
              @remote_file_reloader.reload(file)
            end
          end

          def remote_file_reloader
            @remote_file_reloader ||= RemoteFileReloader.new(@ctx, theme: @theme, streams: @streams)
          end
        end
      end
    end
  end
end
