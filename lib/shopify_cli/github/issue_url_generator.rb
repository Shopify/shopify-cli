module ShopifyCLI
    module GitHub
        module IssueURLGenerator
            def self.error_url(error)
                title = "#{error.class}: #{error.message}"
                labels = "type:bug"
                stacktrace = error.backtrace.length() < 5 ? error.backtrace : error.backtrace[0..4] # take at most 5 lines from backtrace
                body =  "#{File.read(File.join(ShopifyCLI::ROOT, ".github/ISSUE_TEMPLATE.md"))}## Stacktrace\n\nTraceback:\n\n #{stacktrace.join("\n")}"
                #require 'byebug'; byebug
                query = URI.encode_www_form({title: title, body: body, labels: labels})
                url = "#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}"
                url
              end
        end
    end
end