# frozen_string_literal: true
require_relative "../hot_reload/remote_file_reloader"
require_relative "../hot_reload/remote_file_deleter"
require "shopify_cli/theme/ignore_helper"

module ShopifyCLI
  module Theme
    class DevServer
      module Hooks
        class FileChangeHook
          include ShopifyCLI::Theme::IgnoreHelper

          attr_reader :include_filter, :ignore_filter

          def initialize(ctx, theme:, include_filter: nil, ignore_filter: nil)
            @ctx = ctx
            @theme = theme
            @include_filter = include_filter
            @ignore_filter = ignore_filter
          end

          def call(modified, added, removed, streams: nil)
            @streams = streams
            files = (modified + added)
              .map { |f| @theme[f] }
              .reject { |f| ignore_file?(f) }
            files -= liquid_css_files = files.select(&:liquid_css?)
            deleted_files = removed
              .map { |f| @theme[f] }
              .reject { |f| ignore_file?(f) }

            remote_delete(deleted_files) unless deleted_files.empty?
            reload_page(removed) unless deleted_files.empty?

            hot_reload(files) unless files.empty?
            remote_reload(liquid_css_files)
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

          def remote_reload(files)
            files.each do |file|
              @ctx.debug("reload file each -> file.relative_path #{file.relative_path}")
              remote_file_reloader.reload(file)
            end
          end

          def remote_delete(files)
            files.each do |file|
              @ctx.debug("delete file each -> file.relative_path #{file.relative_path}")
              remote_file_deleter.delete(file)
            end
          end

          def remote_file_deleter
            @remote_file_deleter ||= HotReload::RemoteFileDeleter.new(@ctx, theme: @theme, streams: @streams)
          end

          def remote_file_reloader
            @remote_file_reloader ||= HotReload::RemoteFileReloader.new(@ctx, theme: @theme, streams: @streams)
          end
        end
      end
    end
  end
end
