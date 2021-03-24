# frozen_string_literal: true

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

        def initialize(config)
          @config = config
          @pending_files = Set.new
          @checksums = {}
          @ignore_filter = IgnoreFilter.new(root, patterns: config.ignore_files, files: config.ignores)
        end

        def root
          @config.root
        end

        def id
          @config.theme_id
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
          assets = if api_response["asset"]
            [api_response["asset"]]
          else
            api_response["assets"]
          end

          @checksums = assets.each_with_object({}) do |asset, hash|
            hash[asset["key"]] = asset["checksum"]
          end
        end

        def ignore?(file)
          @ignore_filter.match?(self[file].path.to_s)
        end
      end
    end
  end
end
