module ShopifyCli
  module Resources
    class Tokens
      class << self
        def admin(ctx)
          ShopifyCli::DB.get(:admin_access_token) do
            ShopifyCli::Tasks::AuthenticateShopify.call(ctx)
            ShopifyCli::DB.get(:admin_access_token)
          end
        end

        def identity(ctx)
          ShopifyCli::DB.get(:identity_exchange_token) do
            ShopifyCli::Tasks::AuthenticateIdentity.call(ctx)
            ShopifyCli::DB.get(:identity_exchange_token)
          end
        end
      end
    end
  end
end
