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

        def write(res)
          File.write(File.join(ShopifyCli::TEMP_DIR, ".#{file_name}"), res['access_token'])
        end

        def file_name
          project = ShopifyCli::Project.current
          env = Helpers::EnvFile.read(project.app_type,
            File.join(project.directory, '.env'))
          @file_name = env.api_key
        end
      end
    end
  end
end
