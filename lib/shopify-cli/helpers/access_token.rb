module ShopifyCli
  module Helpers
    class AccessToken
      class << self
        def read(ctx)
          access_token || begin
            unless File.file?("#{ShopifyCli::TEMP_DIR}/.access_token")
              ShopifyCli::Tasks::AuthenticateShopify.call(ctx)
            end
            File.read(
              File.join(ShopifyCli::TEMP_DIR, ".access_token")
            )
          end
        end

        def write(res)
          body = JSON.parse(res.body)
          File.write(File.join(ShopifyCli::TEMP_DIR, '.access_token'), body['access_token'])
        end
      end
    end
  end
end
