module Script
  module Layers
    module Infrastructure
      class ScriptUploader
        def initialize(script_service)
          @script_service = script_service
        end

        def upload(script_content)
          upload_details = @script_service.generate_module_upload_url
          url = URI(upload_details[:url])

          https = Net::HTTP.new(url.host, url.port)
          https.use_ssl = true

          request = Net::HTTP::Put.new(url)
          request["Content-Type"] = "application/wasm"

          upload_details[:headers].each do |header, value|
            request[header] = value
          end

          request.body = script_content

          response = https.request(request)
          raise Errors::ScriptUploadError unless response.code == "200"

          upload_details[:url]
        end
      end
    end
  end
end
