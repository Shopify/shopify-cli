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
        stacktrace_text = @error.backtrace.join("\n").to_s
        query = URI.encode_www_form({
          title: "[Bug]: #{@error.class}: #{@error.message}",
          labels: ["type:bug"],
          template: "bug_report.yaml",
          stack_trace: stacktrace_text,
          os: RUBY_PLATFORM,
          cli_version: ShopifyCLI::VERSION,
          ruby_version: "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}",
        })
        url = "#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}"
        generated_url = IssueURLGenerator.error_url(@error)
        assert_equal url, generated_url
      end
    end
  end
end
