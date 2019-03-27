# frozen_string_literal: true

module ShopifyCli
  module Helpers
    class EnvFileHelper
      def initialize(app_type, ctx)
        @ctx = ctx
        key = ctx.app_metadata[:apiKey]
        secret = ctx.app_metadata[:sharedSecret]
        host = ctx.app_metadata[:host]
        @env_content = app_type.class.env_file(key, secret, host)
      end

      def write(path)
        @ctx.print_task('writing .env file')
        @ctx.write(path, @env_content)
      end
    end
  end
end
