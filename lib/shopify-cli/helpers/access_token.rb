module ShopifyCli
  module Helpers
    module AccessToken
      def access_token
        access_token ||= begin
          File.read(
            File.join(ShopifyCli::TEMP_DIR, ".access_token")
          )
        end
      end
    end
  end
end
