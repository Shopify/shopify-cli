module ShopifyCli
  module Resources
    class AccessToken
      class << self
        def read(ctx)
          ShopifyCli::DB.get(:admin_access_token) do
            ShopifyCli::Tasks::AuthenticateShopify.call(ctx)
            ShopifyCli::DB.get(:admin_access_token)
          end
        end
      end
    end
  end
end
