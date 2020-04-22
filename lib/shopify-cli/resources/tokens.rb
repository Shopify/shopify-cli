module ShopifyCli
  module Resources
    class Tokens
      class << self
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
