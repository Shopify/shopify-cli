# frozen_string_literal: true
require "base64"
require "json"

module Extension
  module Models
    module SpecificationHandlers
      class OnlineStoreThemeExtension < Default
        def create(directory_name, context)
          Dir.mkdir(directory_name)
          context.root = File.join(context.root, directory_name)
        end

        def config(context)
          Dir.chdir(context.root) do
            {
              "theme_extension" => {
                "files" => Dir.glob("**/*").select { |filename| File.file?(filename) }.map do |filename|
                  [filename, Base64.encode64(File.read(filename))]
                end.to_h,
                "delete" => [],
              },
            }
          end
        end

        def name
          "Theme Extension"
        end
      end
    end
  end
end
