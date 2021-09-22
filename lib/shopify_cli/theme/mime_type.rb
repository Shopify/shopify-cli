# frozen_string_literal: true
require "webrick"

module ShopifyCLI
  module Theme
    class MimeType < Struct.new(:name)
      MIME_TYPES = WEBrick::HTTPUtils::DefaultMimeTypes.merge(
        "liquid" => "text/x-liquid",
      )

      class << self
        def by_filename(filename)
          new(WEBrick::HTTPUtils.mime_type(filename.to_s, MIME_TYPES))
        end
      end

      def text?
        /text/.match?(name) || json? || javascript?
      end

      def json?
        name == "application/json"
      end

      def javascript?
        name == "application/javascript"
      end

      def to_s
        name
      end
    end
  end
end
