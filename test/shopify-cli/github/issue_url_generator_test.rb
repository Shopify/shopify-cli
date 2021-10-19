require "test_helper"

module ShopifyCLI
  module GitHub
    class IssueURLGeneratorTest < MiniTest::Test
      def setup
        super
        @ctx = ShopifyCLI::Context.new
        @error = stub(backtrace: ["Backtrace Line 1", "Backtrace Line 2"], class: "Runtime Error",
message: "Error Message")
      end

      def test_call_error_url
        file = File.join(ShopifyCLI::ROOT, ".github/ISSUE_TEMPLATE.md")
        assert File.exist?(file)
        body = File.read(file) + "## Stacktrace\n\nTraceback:\n\n #{@error.backtrace.join("\n")}"
        query = URI.encode_www_form({ title: "#{@error.class}: #{@error.message}", body: body, labels: "type:bug" })
        url = "#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}"
        generated_url = IssueURLGenerator.error_url(@error)
        assert_equal url, generated_url
      end
    end
  end
end
