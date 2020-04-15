module ShopifyCli
  module Helpers
    class PkceToken
      class << self
        def read(ctx)
          ShopifyCli::DB.get(:identity_exchange_token) do
            ShopifyCli::Tasks::AuthenticateIdentity.call(ctx)
            ShopifyCli::DB.get(:identity_exchange_token)
          end
        end
      end
    end
  end
end
