# frozen_string_literal: true
require_relative "../syncer"
require_relative "../development_theme"
require "shopify_cli/git"
require "tmpdir"
require "fileutils"

module ShopifyCLI
  module Theme
    module Extension
      # TODO: MOVEEEEEEE
      class HostThemeProgressBar
        GIT_CLONE_PROGRESS_SHARE = 0.2
        SYNC_PROGRESS_SHARE = 0.8

        def initialize(syncer, dir)
          # TODO: fix sig
          @syncer = syncer
          @dir = dir
        end

        def progress(method, **args)
          @syncer.lock_io!
          CLI::UI::Progress.progress do |bar|
            Git.public_send(:clone, "https://github.com/Shopify/dawn.git", @dir) do |percent|
              bar.tick(set_percent: percent * GIT_CLONE_PROGRESS_SHARE)
            end

            @syncer.public_send(method, **args) do |left, total|
              bar.tick(set_percent: (1 - left.to_f / total) * SYNC_PROGRESS_SHARE + GIT_CLONE_PROGRESS_SHARE)
            end

            bar.tick(set_percent: 1)
          end
          @syncer.unlock_io!
        end
      end

      class HostTheme < DevelopmentTheme
        def id
          ShopifyCLI::DB.get(:host_theme_id)
        end

        def name
          existing_name = ShopifyCLI::DB.get(:host_theme_name)
          if existing_name.nil? || existing_name.length > API_NAME_LIMIT
            generate_host_theme_name
          else
            existing_name
          end
        end

        def ensure_exists!
          # TODO: put pack

          # if exists?
          #   @ctx.debug("Using temporary host theme: ##{id} #{name}")
          # else
          create
          @ctx.debug("Created temporary host theme: #{@id}")
          # end

          self
        end

        def delete
          delete_theme if exists? # Avoid deleting any existing development theme logic

          ShopifyCLI::DB.del(:host_theme_id) if ShopifyCLI::DB.exists?(:host_theme_id)
          ShopifyCLI::DB.del(:host_theme_name) if ShopifyCLI::DB.exists?(:host_theme_name)
        end

        def create
          super
          ShopifyCLI::DB.set(host_theme_id: @id)

          generate_tmp_theme
        end

        def self.find_or_create!(ctx)
          new(ctx, root: nil).ensure_exists!
        end

        private

        def generate_host_theme_name
          hostname = Socket.gethostname.split(".").shift
          hash = SecureRandom.hex(3)

          theme_name = "App Ext. Host ()"
          hostname_character_limit = API_NAME_LIMIT - theme_name.length - hash.length - 1
          identifier = encode_identifier("#{hash}-#{hostname[0, hostname_character_limit]}")
          theme_name = "App Ext. Host (#{identifier})"

          ShopifyCLI::DB.set(host_theme_name: theme_name)

          theme_name
        end

        def generate_tmp_theme
          Dir.mktmpdir do |dir|
            @root = Pathname.new(dir)
            @ctx.root = dir
            syncer = Syncer.new(@ctx, theme: self)

            begin
              syncer.start_threads
              ::CLI::UI::Frame.open(@ctx.message("theme.push.info.pushing", name, id, shop)) do
                # TODO: move to other file
                HostThemeProgressBar.new(syncer, dir).progress(:upload_theme!, delete: false)
              end
            rescue Errno::ENOENT => e
              @ctx.debug(e.message)
            ensure
              syncer.shutdown
            end
          end
        end
      end
    end
  end
end
