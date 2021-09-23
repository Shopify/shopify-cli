# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/mime_type"

module ShopifyCLI
  module Theme
    class MimeTypeTest < Minitest::Test
      def test_by_filename
        assert_equal("text/css", MimeType.by_filename("assets/style.css").name)
        assert_equal("application/javascript", MimeType.by_filename("assets/site.js").name)
        assert_equal("image/gif", MimeType.by_filename("assets/image.gif").name)
        assert_equal("text/x-liquid", MimeType.by_filename("templates/template.liquid").name)
        assert_equal("application/octet-stream", MimeType.by_filename("template.unknown").name)
      end

      def test_text
        assert(MimeType.by_filename("assets/style.css").text?)
        assert(MimeType.by_filename("assets/site.js").text?)
        refute(MimeType.by_filename("assets/image.gif").text?)
        assert(MimeType.by_filename("templates/template.liquid").text?)
        refute(MimeType.by_filename("templates/template.unknown").text?)
      end
    end
  end
end
