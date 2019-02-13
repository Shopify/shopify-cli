module ShopifyCli
  module Helpers
    class KeysHelper
      def initialize(app_type, ctx)
        key = ctx.app_metadata['apiKey']
        secret = ctx.app_metadata['sharedSecret']
        host = ctx.app_metadata[:host]
        @env_content = app_type.class.keys(key, secret, host)
      end

      def write(path)
        File.write(path, @env_content)
      end
    end
  end
end
