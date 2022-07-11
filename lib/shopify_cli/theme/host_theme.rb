# frozen_string_literal: true
require_relative "theme"
require_relative "shopify_cli/git"
require_relative "syncer"
require "tmpdir"
require "fileutils"

module ShopifyCLI
  module Theme
    class HostTheme < DevelopmentTheme
      def id
        ShopifyCLI::DB.get(:host_theme_id)
      end

      def name
        existing = ShopifyCLI:DB.get(:host_theme_name)
        if existing_name.nil? || existing_name.length > API_NAME_LIMIT
          generate_host_theme_name
        else
          existing_name
        end
      end

      def ensure_exists!
        if exists?
          @ctx.debug("Using temporary host theme: ##{id} #{name}")
        else
          create
          @ctx.debug("Created temporary host theme: #{@id}")
          ShopifyCLI::DB.set(host_theme_id: @id)
        end

        self
      end

      def delete
        raise StandardError.new("Couldn't get @dir") unless @dir
        FileUtils.remove_entry @dir
        ShopifyCLI::DB.del(:host_theme_id) if ShopifyCLI::DB.exists?(:host_theme_id)
        ShopifyCLI::DB.del(:host_theme_name) if ShopifyCLI::DB.exists?(:host_theme_name)
      end

      def create
        @dir = Dir.mktmpdir
        Git.clone("https://github.com/Shopify/dawn.git", @dir)

        @ctx.root = File.join(@ctx.root, name)
        syncer = Syncer.new(@ctx, theme: self)

        begin
          @ctx.rm_r(".git")
          @ctx.rm_r(".github")
          syncer.start_threads
          syncer.upload_theme!(delete: false)
        rescue Errno::ENOENT => e
          @ctx.debug(e)
        ensure
          syncer.shutdown
        end
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
    end
  end
end
