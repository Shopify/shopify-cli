module ShopifyCli
  module Helpers
    class AccessToken
      class << self
        def read(ctx)
          unless File.file?("#{ShopifyCli::TEMP_DIR}/.#{file_name}")
            ShopifyCli::Tasks::AuthenticateShopify.call(ctx)
          end
          File.read(
            File.join(ShopifyCli::TEMP_DIR, ".#{file_name}")
          )
        end

        def write(token)
          File.write(File.join(ShopifyCli::TEMP_DIR, ".#{file_name}"), token)
        end

        def file_name
          env = Helpers::EnvFile.read
          @file_name = env.api_key
        end
      end
    end
  end
end
