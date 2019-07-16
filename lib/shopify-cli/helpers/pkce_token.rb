module ShopifyCli
  module Helpers
    class PkceToken
      class << self
        def read(ctx)
          ShopifyCli::Tasks::AuthenticateIdentity.call(ctx) unless File.file?(file_name)
          File.read(file_name)
        end

        def write(token)
          File.write(file_name, token)
        end

        def file_name
          File.join(ShopifyCli::TEMP_DIR, ".pkce")
        end
      end
    end
  end
end
