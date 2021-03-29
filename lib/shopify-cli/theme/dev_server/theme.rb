# frozen_string_literal: true
require "socket"
require "securerandom"

module ShopifyCli
  module Theme
    module DevServer
      class Theme
        class File < Struct.new(:path)
          attr_reader :relative_path

          def initialize(path, root)
            super(Pathname.new(path))

            # Path may be relative or absolute depending on the source.
            # By converting both the path and the root to absolute paths, we
            # can safely fetch a relative path.
            @relative_path = self.path.expand_path.relative_path_from(root.expand_path)
          end

          def read
            path.read
          end

          # Make it possible to check whether a given File is within a list of Files with `include?`,
          # some of which may be relative paths while others are absolute paths.
          def ==(other)
            relative_path == other.relative_path
          end
        end

        # Files waiting to be uploaded to the Online Store
        attr_reader :pending_files
        attr_reader :config
        attr_reader :checksums

        def initialize(ctx, config)
          @ctx = ctx
          @config = config
          @pending_files = Set.new
          @checksums = {}
          @ignore_filter = IgnoreFilter.new(root, patterns: config.ignore_files, files: config.ignores)
        end

        def root
          @config.root
        end

        def id
          ShopifyCli::DB.get(:development_theme_id)
        end

        def name
          theme_name = ShopifyCli::DB.get(:development_theme_name)
          return theme_name unless theme_name.nil?

          generate_theme_name
        end

        def assets
          root.glob("assets/*").map { |path| File.new(path, root) }
        end

        def theme_files
          root.glob(["**/*.liquid", "**/*.json", "assets/*.css", "assets/*.js"]).map { |path| File.new(path, root) }
        end

        def theme_file?(file)
          theme_files.include?(self[file])
        end

        def asset_paths
          assets.map(&:relative_path)
        end

        def [](file)
          case file
          when File
            file
          when Pathname
            File.new(file, root)
          when String
            File.new(root.join(file), root)
          end
        end

        def assets_api_uri
          URI("https://#{config.store}/admin/api/2021-01/themes/#{id}/assets.json")
        end

        def file_has_changed?(file)
          Digest::MD5.hexdigest(file.read) != checksums[file.relative_path.to_s]
        end

        def update_checksums!(api_response)
          assets = api_response.values.flatten

          @checksums = assets.each_with_object({}) do |asset, hash|
            hash[asset["key"]] = asset["checksum"]
          end
        end

        def ignore?(file)
          @ignore_filter.match?(self[file].path.to_s)
        end

        def ensure_development_theme_exists!
          create_development_theme unless development_theme_exists?

          @ctx.debug("Using temporary development theme: ##{id} #{name}")
        end

        private

        def development_theme_exists?
          return false unless id

          ShopifyCli::AdminAPI.rest_request(
            @ctx,
            shop: ShopifyCli::DB.get(:shop),
            path: "themes/#{id}",
            api_version: "unstable",
          )
        rescue ShopifyCli::API::APIRequestNotFoundError
          false
        end

        def create_development_theme
          _status, body = ShopifyCli::AdminAPI.rest_request(
            @ctx,
            shop: ShopifyCli::DB.get(:shop),
            path: "themes",
            body: {
              theme: {
                name: name,
                role: "development",
              },
            },
            method: "POST",
            api_version: "unstable",
          )

          theme_id = body["id"]

          @ctx.debug("Created temporary development theme: #{theme_id}")

          ShopifyCli::DB.set(:development_theme_id, theme_id)
        end

        def generate_theme_name
          hostname = Socket.gethostname.split(".").shift
          hash = SecureRandom.hex[0..5]

          theme_name = "Development #{hash} (#{hostname})"

          ShopifyCli::DB.set(:development_theme_name, theme_name)

          theme_name
        end
      end
    end
  end
end
