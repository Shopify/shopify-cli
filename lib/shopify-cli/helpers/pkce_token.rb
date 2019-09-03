module ShopifyCli
  module Helpers
    class PkceToken
      class << self
        def read(ctx)
          Store.get(:identity_exchange_token) do
            ShopifyCli::Tasks::AuthenticateIdentity.call(ctx)
            Store.get(:identity_exchange_token)
          end
        end
      end
    end
  end
end
