module ShopifyCLI
    module GitHub
        module IssueURLGenerator
            def self.error_url(error)
                title = "Title"
                labels = "type:bug"
                body = File.read(File.join(ShopifyCLI::ROOT, ".github/ISSUE_TEMPLATE.md"))
                stacktrace_message = "## Stacktrace\n\nTraceback:\n\n"
                stacktrace = error.backtrace.length() < 5 ? error.backtrace : error.backtrace[0..4] # take at most 5 lines from backtrace
                stacktrace.each do |e|
                    stacktrace_message += e
                    stacktrace_message += "\n"
                end
                body += stacktrace_message
                # require 'byebug'; byebug
                query = URI.encode_www_form({title: title, body: body, labels: labels})
                url = "#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}"
                url
              end
        end
    end
end