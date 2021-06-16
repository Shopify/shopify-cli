# frozen_string_literal: true
require "base64"
require "json"

module Extension
  module Models
    module SpecificationHandlers
      APP_BLOCK_SAMPLE = <<~BLOCK
        Your theme app extension's liquid goes here.

        {% schema %}
        {
          "name": "Sample App Block",
          "target": "section"
        }
        {% endschema %}
      BLOCK

      APP_EMBED_BLOCK_SAMPLE = <<~BLOCK
        Your theme app extension's liquid goes here and will be rendered inside
        the <head> section of product pages.

        {% schema %}
        {
          "name": "Sample App Embed Block",
          "target": "head",
          "templates": ["product"]
        }
        {% endschema %}
      BLOCK

      class ThemeAppExtension < Default
        SUPPORTED_BUCKETS = %w(assets blocks snippets locales)

        def create(directory_name, context)
          context.root = File.join(context.root, directory_name)

          FileUtils.makedirs(SUPPORTED_BUCKETS.map { |b| File.join(context.root, b) })
          File.write(File.join(context.root, "blocks", "app_block_sample.liquid"), APP_BLOCK_SAMPLE)
          File.write(File.join(context.root, "blocks", "app_embed_block_sample.liquid"), APP_EMBED_BLOCK_SAMPLE)
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
          "Theme App Extension"
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
