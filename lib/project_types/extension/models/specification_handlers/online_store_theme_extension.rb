# frozen_string_literal: true
require "base64"
require "json"

module Extension
  module Models
    module SpecificationHandlers
      class OnlineStoreThemeExtension < Default
        SUPPORTED_BUCKETS = %w(assets blocks snippets locales)
        def create(directory_name, context)
          context.root = File.join(context.root, directory_name)
          FileUtils.mkdir_p(context.root)
        end

        def config(context)
          Dir.chdir(context.root) do
            Dir["**/*"].select { |filename| File.file?(filename) && validate(filename) }
              .map { |filename| [filename, Base64.encode64(File.read(filename))] }
              .yield_self do |encoded_files_by_name|
                { "theme_extension" => { "files" => encoded_files_by_name.to_h } }
              end
          end
        end

        def name
          "Online Store Theme Extension"
        end

        private

        def validate(filename)
          dirname = File.dirname(filename)
          return true if SUPPORTED_BUCKETS.include?(dirname)
          raise Extension::Errors::InvalidDirectoryError, "Invalid directory: #{dirname}"
        end
      end
    end
  end
end
