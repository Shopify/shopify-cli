# frozen_string_literal: true
require "base64"
require "json"
require "shopify_cli/theme/extension/dev_server"

module Extension
  module Models
    module SpecificationHandlers
      class ThemeAppExtension < Default
        SUPPORTED_BUCKETS = %w(assets blocks snippets locales)
        BUNDLE_SIZE_LIMIT = 10 * 1024 * 1024 # 10MB
        LIQUID_SIZE_LIMIT = 100 * 1024 # 100kb
        SUPPORTED_ASSET_EXTS = %w(.jpg .js .css .png .svg)
        SUPPORTED_LOCALE_EXTS = %w(.json)

        def create(directory_name, context, getting_started: false)
          context.root = File.join(context.root, directory_name)

          if getting_started
            ShopifyCLI::Git.clone("https://github.com/Shopify/theme-extension-getting-started", context.root)
            context.rm_r(".git")
          else
            FileUtils.makedirs(SUPPORTED_BUCKETS.map { |b| File.join(context.root, b) })
          end
        end

        def config(context)
          current_size = 0
          current_liquid_size = 0
          Dir.chdir(context.root) do
            Dir["**/*"].select { |filename| File.file?(filename) && validate(filename) }
              .map do |filename|
                dirname = File.dirname(filename)
                if dirname == "assets"
                  # Assets should be read as binary data, since they could be images
                  mode = "rb"
                  encoding = "BINARY"
                else
                  # Other assets should be treated as UTF-8 encoded text
                  mode = "rt"
                  encoding = "UTF-8"

                  if dirname == "snippets" || dirname == "blocks"
                    current_liquid_size += File.size(filename)
                  end
                end
                current_size += File.size(filename)
                if current_size > BUNDLE_SIZE_LIMIT
                  raise Extension::Errors::BundleTooLargeError,
                    "Total size of all files must be less than #{CLI::Kit::Util.to_filesize(BUNDLE_SIZE_LIMIT)}"
                end
                if current_liquid_size > LIQUID_SIZE_LIMIT
                  raise Extension::Errors::BundleTooLargeError,
                    "Total size of all liquid must be less than #{CLI::Kit::Util.to_filesize(LIQUID_SIZE_LIMIT)}"
                end
                [filename, Base64.encode64(File.read(filename, mode: mode, encoding: encoding))]
              end
              .yield_self do |encoded_files_by_name|
                { "theme_extension" => { "files" => encoded_files_by_name.to_h } }
              end
          end
        end

        def name
          "Theme App Extension"
        end

        def choose_port?(_ctx)
          false
        end

        def establish_tunnel?(_ctx)
          false
        end

        def serve(**options)
          @ctx = options[:context]
          root = options[:context]&.root
          project = options[:project]
          properties = options
            .slice(:port, :theme, :generate_tmp_theme)
            .compact
            .merge({
              project: project,
              specification_handler: self,
            })

          ShopifyCLI::Theme::Extension::DevServer.start(@ctx, root, **properties)
        end

        private

        def validate(filename)
          dirname = File.dirname(filename)
          # Skip files in the root of the directory tree
          return false if dirname == "."

          unless SUPPORTED_BUCKETS.include?(dirname)
            raise Extension::Errors::InvalidFilenameError, "Invalid directory: #{dirname}"
          end

          ext = File.extname(filename)
          if dirname == "assets"
            unless SUPPORTED_ASSET_EXTS.include?(ext)
              raise Extension::Errors::InvalidFilenameError,
                "Invalid filename: #{filename}; #{ext} is not supported"
            end
          elsif dirname == "locales"
            unless SUPPORTED_LOCALE_EXTS.include?(ext)
              raise Extension::Errors::InvalidFilenameError,
                "Invalid filename: #{filename}; Only #{SUPPORTED_LOCALE_EXTS.join(", ")} allowed in #{dirname}"
            end
          elsif ext != ".liquid"
            raise Extension::Errors::InvalidFilenameError,
              "Invalid filename: #{filename}; Only .liquid allowed in #{dirname}"
          end
          true
        end
      end
    end
  end
end
