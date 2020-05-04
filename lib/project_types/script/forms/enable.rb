# frozen_string_literal: true

module Script
  module Forms
    class Enable < ScriptForm
      flag_arguments :api_key, :shop_domain

      def ask
        self.api_key ||= ask_api_key
        self.shop_domain ||= ask_shop_domain
      end

      private

      def ask_api_key
        ask_app_api_key(ctx, organization['apps'], message: 'Which app is the script deployed to?')
      end

      def ask_shop_domain
        super(ctx, organization, message: 'Which development store is the app installed on?')
      end
    end
  end
end
