# typed: strict
module ShopifyCLI
  module GitHub
    module IssueURLGenerator
      extend T::Sig

      sig { params(error: StandardError).returns(String) }
      def self.error_url(error)
        title = "#{error.class}: #{error.message}"
        labels = "type:bug"
        content = File.read(File.join(ShopifyCLI::Constants::Paths::ROOT, ".github/ISSUE_TEMPLATE.md"))
        stacktrace = error.backtrace
        stacktrace = [] if stacktrace.nil?

        # take at most 5 lines from backtrace
        stacktrace = T.must(stacktrace[0..4])
        body = stacktrace.join("\n").to_s
        output = content.gsub(/<!--Stacktrace(.|\n)*-->/, body)
        query = URI.encode_www_form({ title: title, body: output, labels: labels })
        url = "#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}"
        url
      end
    end
  end
end
