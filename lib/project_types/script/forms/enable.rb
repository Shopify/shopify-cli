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
        ask_app_api_key(organization['apps'], message: ctx.message('script.forms.enable.ask_app_api_key'))
      end

      def ask_shop_domain
        super(organization, message: ctx.message('script.forms.enable.ask_shop_domain'))
      end
    end
  end
end
