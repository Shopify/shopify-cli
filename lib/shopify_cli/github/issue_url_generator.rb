module ShopifyCLI
    module GitHub
        module IssueURLGenerator
            def self.error_url(error)
                title = "Title"
                body = "Body"
                labels = "type:bug"
                template = File.read(File.join(ShopifyCLI::ROOT, ".github/ISSUE_TEMPLATE.md"))
                query = URI.encode_www_form({title: title, body: template, labels: labels})
                url = "#{ShopifyCLI::Constants::Links::NEW_ISSUE}?#{query}"
                url
              end
        end
    end
end