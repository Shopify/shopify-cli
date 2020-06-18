# frozen_string_literal: true
require 'base64'

module Extension
  module Features
    module TunnelUrl
      NGROK_TUNNELS_URI = URI.parse('http://localhost:4040/api/tunnels')
      TUNNELS_FIELD = 'tunnels'
      PUBLIC_URL_FIELD = 'public_url'

      def self.fetch
        begin
          response = Net::HTTP.get_response(NGROK_TUNNELS_URI)
          json = JSON.parse(response.body)
          return json.dig(TUNNELS_FIELD, 0, PUBLIC_URL_FIELD)
        rescue
          return nil
        end
      end
    end
  end
end
