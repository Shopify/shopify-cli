# frozen_string_literal: true
require_relative "syncer"
require_relative "development_theme"
require "shopify_cli/git"
require "tmpdir"
require "fileutils"

module ShopifyCLI
  module Theme
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
        if exists?
          generate_tmp_theme
          @ctx.debug("Using temporary host theme: ##{id} #{name}")
        else
          create
          @ctx.debug("Created temporary host theme: #{@id}")
        end

        self
      end

      def clear
        @dir ||= ShopifyCLI::DB.get(:host_theme_dir)
        raise StandardError.new("Couldn't get @dir") unless @dir
        FileUtils.remove_entry @dir
      end

      def delete
        clear
        super if exists?

        ShopifyCLI::DB.del(:host_theme_id) if ShopifyCLI::DB.exists?(:host_theme_id)
        ShopifyCLI::DB.del(:host_theme_name) if ShopifyCLI::DB.exists?(:host_theme_name)
        ShopifyCLI::DB.del(:host_theme_dir) if ShopifyCLI::DB.exists?(:host_theme_dir)
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
        @dir = Dir.mktmpdir
        ShopifyCLI::DB.set(host_theme_dir: @dir)

        @root = Pathname.new(@dir)
        @ctx.root = @dir
        Git.clone("https://github.com/Shopify/dawn.git", @dir)

        syncer = Syncer.new(@ctx, theme: self)

        begin
          syncer.start_threads
          ::CLI::UI::Frame.open(@ctx.message("theme.push.info.pushing", name, id, shop)) do
            syncer.upload_theme!(delete: false)
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
