require "test_helper"

module ShopifyCLI
  module GitHub
    class IssueURLGeneratorTest < MiniTest::Test
    
        def setup
            super
            @ctx = ShopifyCLI::Context.new
            @command = IssueURLGenerator.new(@ctx)
            @error = stub(backtrace: ["Backtrace Line 1", "Backtrace Line 2"], class: "Runtime Error", message: "Error Message")
        end

      def test_call_error_url
        file = File.join(ShopifyCLI::ROOT, ".github/ISSUE_TEMPLATE.md")
        assert(File.exist?(file))
        body = FIle.read(file) + "## Stacktrace\n\nTraceback:\n\n #{@error.backtrace.join("\n")}"
        query = URI.encode_www_form({title: "#{@error.class}: #{@error.message}", body: body, labels: "type:bug"})
        @ctx.expects("#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}")
        @command.error_url(@error)
      end
    end
  end
end
