# frozen_string_literal: true
require "base64"
require "json"

module Extension
  module Models
    module SpecificationHandlers
      class OnlineStoreAppExtension < Default
        SUPPORTED_BUCKETS = %w(assets blocks snippets locales)
        def create(directory_name, context)
          context.root = File.join(context.root, directory_name)
          FileUtils.mkdir_p(context.root)
        end

        def config(context)
          Dir.chdir(context.root) do
            {
              "theme_extension" => {
                "files" => Dir.glob("**/*").select { |filename| File.file?(filename) }.map do |filename|
                  validate(filename)
                  [filename, Base64.encode64(File.read(filename))]
                end.to_h,
              },
            }
          end
        end

        def name
          "Online Store App Extension"
        end

        private

        def validate(filename)
          # TODO: Check that the toplevel directory is correct
          dirname = File.dirname(filename)
          raise(
            Extension::Errors::InvalidDirectoryError,
            "Invalid directory: #{dirname}"
          ) unless SUPPORTED_BUCKETS.include?(dirname)
        end
      end
    end
  end
end
