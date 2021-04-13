# frozen_string_literal: true
require "socket"
require "securerandom"

module ShopifyCli
  module Theme
    module DevServer
      class Theme
        class File < Struct.new(:path)
          attr_reader :relative_path
          attr_accessor :remote_checksum

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

          def mime_type
            @mime_type ||= MimeType.by_filename(relative_path)
          end

          def text?
            mime_type.text?
          end

          def liquid?
            path.extname == ".liquid"
          end

          def json?
            path.extname == ".json"
          end

          def template?
            relative_path.to_s.start_with?("templates/")
          end

          def checksum
            content = read
            if mime_type.json?
              # Normalize JSON to match backend
              begin
                content = JSON.generate(JSON.parse(content))
              rescue JSON::JSONError
                # Fallback to using the raw content
              end
            end
            Digest::MD5.hexdigest(content)
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
        attr_reader :remote_checksums

        def initialize(ctx, config)
          @ctx = ctx
          @config = config
          @pending_files = Set.new
          @remote_checksums = {}
          @ignore_filter = IgnoreFilter.new(root, patterns: config.ignore_files, files: config.ignores)
        end

        def root
          @config.root
        end

        def id
          ShopifyCli::DB.get(:development_theme_id)
        end

        def name
          ShopifyCli::DB.get(:development_theme_name) || generate_theme_name
        end

        def theme_files
          glob(["**/*.liquid", "**/*.json", "assets/*"])
        end

        def asset_files
          glob("assets/*")
        end

        def liquid_files
          glob("**/*.liquid")
        end

        def json_files
          glob("**/*.json")
        end

        def glob(pattern)
          root.glob(pattern).map { |path| File.new(path, root) }
        end

        def theme_file?(file)
          theme_files.include?(self[file])
        end

        def asset_paths
          asset_files.map(&:relative_path)
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

        def shop
          AdminAPI.get_shop(@ctx)
        end

        def file_has_changed?(file)
          file.checksum != remote_checksums[file.relative_path.to_s]
        end

        def update_remote_checksums!(api_response)
          assets = api_response.values.flatten

          assets.each do |asset|
            @remote_checksums[asset["key"]] = asset["checksum"]
          end
        end

        def ignore?(file)
          @ignore_filter.match?(self[file].path.to_s)
        end

        def ensure_development_theme_exists!
          create_development_theme unless development_theme_exists?

          @ctx.debug("Using temporary development theme: ##{id} #{name}")
        end

        def editor_url
          "https://#{shop}/admin/themes/#{id}/editor"
        end

        def preview_url
          "https://#{shop}/?preview_theme_id=#{id}"
        end

        private

        def development_theme_exists?
          return false unless id

          ShopifyCli::AdminAPI.rest_request(
            @ctx,
            shop: shop,
            path: "themes/#{id}.json",
            api_version: "unstable",
          )
        rescue ShopifyCli::API::APIRequestNotFoundError
          false
        end

        def create_development_theme
          _status, body = ShopifyCli::AdminAPI.rest_request(
            @ctx,
            shop: shop,
            path: "themes.json",
            body: JSON.generate({
              theme: {
                name: name,
                role: "development",
              },
            }),
            method: "POST",
            api_version: "unstable",
          )

          theme_id = body["theme"]["id"]

          @ctx.debug("Created temporary development theme: #{theme_id}")

          ShopifyCli::DB.set(development_theme_id: theme_id)
        end

        def generate_theme_name
          hostname = Socket.gethostname.split(".").shift
          hash = SecureRandom.hex(3)

          theme_name = "Development (#{hash}-#{hostname})"

          ShopifyCli::DB.set(development_theme_name: theme_name)

          theme_name
        end
      end
    end
  end
end
