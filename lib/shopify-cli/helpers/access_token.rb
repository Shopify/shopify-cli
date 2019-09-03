module ShopifyCli
  module Helpers
    class AccessToken
      class << self
        def read(ctx)
          Store.get(:admin_access_token) do
            ShopifyCli::Tasks::AuthenticateShopify.call(ctx)
            Store.get(:admin_access_token)
          end
        end
      end
    end
  end
end
