# frozen_string_literal: true
require_relative "mime_type"

module ShopifyCLI
  module Theme
    class File < Struct.new(:path)
      attr_accessor :remote_checksum
      attr_writer :warnings

      def initialize(path, root)
        super(Pathname.new(path))

        # Path may be relative or absolute depending on the source.
        # By converting both the path and the root to absolute paths, we
        # can safely fetch a relative path.
        @relative_path = self.path.expand_path.relative_path_from(root.expand_path)
      end

      def read
        if text?
          path.read(universal_newline: true)
        else
          path.read(mode: "rb")
        end
      end

      def write(content)
        path.parent.mkpath unless path.parent.directory?
        if text?
          path.write(content, universal_newline: true)
        else
          path.write(content, 0, mode: "wb")
        end
      rescue Encoding::UndefinedConversionError
        ##
        # The CLI tries to write the file and normalize EOL characters to avoid
        # errors on Windows when files are shared across different operational systems.
        #
        # The CLI fallbacks any error during the conversion by writing the file
        # in binary mode when the normalization fails (e.g., ASCII files), so no data is lost.
        #
        path.write(content, 0, mode: "wb")
      end

      def delete
        path.delete
      end

      def exist?
        path.exist?
      end

      def mime_type
        @mime_type ||= MimeType.by_filename(@relative_path)
      end

      def text?
        mime_type.text?
      end

      def liquid?
        path.extname == ".liquid"
      end

      def liquid_css?
        relative_path.end_with?(".css.liquid")
      end

      def json?
        path.extname == ".json"
      end

      def template?
        relative_path.start_with?("templates/")
      end

      def checksum
        content = read
        if mime_type.json?
          # Normalize JSON to match backend
          begin
            content = normalize_json(content)
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

      def name(*args)
        ::File.basename(path, *args)
      end

      def absolute_path
        path.realpath.to_s
      end

      def relative_path
        @relative_path.to_s
      end

      def warnings
        @warnings || []
      end

      private

      def normalize_json(content)
        parsed = JSON.parse(content)

        if template?
          JsonTemplateNormalizer.new.visit_document(parsed)
        end

        normalized = JSON.generate(parsed)
        # Backend escapes forward slashes
        normalized.gsub!(/\//, "\\/")
        normalized
      end

      class JsonTemplateNormalizer
        def visit_document(value)
          visit_hash(value["sections"])
        end

        def visit_hash(hash)
          return unless hash.is_a?(Hash)
          hash.each do |_, value|
            visit_value(value)
          end
        end

        def visit_value(value)
          # Reinsert settings to force the same ordering as in the backend
          settings = value.delete("settings") || {}
          value["settings"] = settings

          visit_hash(value["blocks"])
        end
      end
    end
  end
end
