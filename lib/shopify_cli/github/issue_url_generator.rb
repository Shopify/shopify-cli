module ShopifyCLI
  module GitHub
    module IssueURLGenerator
      def self.error_url(error)
        title = "[Bug]: #{error.class}: #{error.message}"
        labels = "type:bug"

        # take at most 5 lines from backtrace
        stacktrace_text =
          if error.backtrace # Sometimes errors seem to appear without backtrace, see https://github.com/Shopify/shopify-cli/issues/1972#issuecomment-1028013630
            stacktrace = error.backtrace.length < 5 ? error.backtrace : error.backtrace[0..4]
            stacktrace.join("\n").to_s
          else
            ""
          end
        query = URI.encode_www_form({
          title: title,
          labels: labels,
          template: "bug_report.yaml",
          stack_trace: stacktrace_text,
          os: RUBY_PLATFORM,
          cli_version: ShopifyCLI::VERSION,
          ruby_version: "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}",
          shell: ENV["SHELL"],
        })
        "#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}"
      end
    end
  end
end
