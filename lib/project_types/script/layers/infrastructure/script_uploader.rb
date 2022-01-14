module Script
  module Layers
    module Infrastructure
      class ScriptUploader
        CONTENT_LENGTH_RANGE_HEADER = "x-goog-content-length-range"

        def initialize(script_service)
          @script_service = script_service
        end

        def upload(script_content)
          upload_details = @script_service.generate_module_upload_details
          url = URI(upload_details[:url])

          https = Net::HTTP.new(url.host, url.port)
          https.use_ssl = true

          request = Net::HTTP::Put.new(url)
          request["Content-Type"] = "application/wasm"

          headers = upload_details[:headers]
          headers.each do |header, value|
            request[header] = value
          end

          request.body = script_content

          response = https.request(request)
          raise Errors::ScriptTooLargeError, file_size_limit(headers) if script_too_large?(response)
          raise Errors::ScriptUploadError unless response.code == "200"

          upload_details[:url]
        end

        private

        def script_too_large?(response)
          response.code == "400" && response.body.include?("EntityTooLarge")
        end

        def file_size_limit(headers)
          content_length_range_value = headers[CONTENT_LENGTH_RANGE_HEADER]
          return 0 unless content_length_range_value
          content_length_range_value.split(",")[1].to_i
        end
      end
    end
  end
end
