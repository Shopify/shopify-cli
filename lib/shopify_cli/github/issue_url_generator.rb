module ShopifyCLI
  module GitHub
    module IssueURLGenerator
      def self.error_url(error)
        title = "[Bug]: #{error.class}: #{error.message}"
        labels = "type:bug"

        # take at most 5 lines from backtrace
        stacktrace = error.backtrace.length < 5 ? error.backtrace : error.backtrace[0..4]
        stacktrace_text = stacktrace.join("\n").to_s
        query = URI.encode_www_form({
          title: title,
          labels: labels,
          template: "bug_report.yaml",
          stack_trace: stacktrace_text,
          os: RbConfig::CONFIG['host_os'],
          cli_version: ShopifyCLI::VERSION,
          ruby_version: "#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}",
        })
        "#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}"
      end
    end
  end
end
