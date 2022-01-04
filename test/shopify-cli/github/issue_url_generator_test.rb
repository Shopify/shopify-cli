# typed: ignore
require "test_helper"

module ShopifyCLI
  module GitHub
    class IssueURLGeneratorTest < MiniTest::Test
      def setup
        super
        @ctx = ShopifyCLI::Context.new
        @error = nil
        begin
          raise StandardError, "Error"
        rescue StandardError => error
          @error = error
        end
      end

      def test_call_error_url
        file = File.read(File.join(ShopifyCLI::ROOT, ".github/ISSUE_TEMPLATE.md"))
        body = @error.backtrace[0..4].join("\n").to_s
        output = file.gsub(/<!--Stacktrace(.|\n)*-->/, body)
        query = URI.encode_www_form({ title: "#{@error.class}: #{@error.message}", body: output, labels: "type:bug" })
        url = "#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}"
        generated_url = IssueURLGenerator.error_url(@error)
        assert_equal url, generated_url
      end
    end
  end
end
