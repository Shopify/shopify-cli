module Script
  module Layers
    module Infrastructure
      class ScriptUploader
        def initialize(script_service)
          @script_service = script_service
        end

        def upload(script_content)
          @script_service.generate_module_upload_url.tap do |url|
            url = URI(url)

            https = Net::HTTP.new(url.host, url.port)
            https.use_ssl = true

            request = Net::HTTP::Put.new(url)
            request["Content-Type"] = "application/wasm"
            request.body = script_content

            response = https.request(request)
            raise Errors::ScriptUploadError unless response.code == "200"
          end
        end
      end
    end
  end
end
