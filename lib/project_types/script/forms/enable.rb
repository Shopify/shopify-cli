# frozen_string_literal: true

module Script
  module Forms
    class Enable < ScriptForm
      flag_arguments :api_key, :shop_domain

      def ask
        if ScriptProject.current.env.nil?
          org = ask_org
          app = ask_app(org)
          self.api_key = app['apiKey']
          write_env(org, api_key, app['apiSecretKeys'].first['secret'], nil)
        else
          self.api_key ||= ScriptProject.current.env[:api_key]
        end

        env = ScriptProject.current.env

        self.shop_domain ||= env[:shop]
        self.shop_domain ||= ask_shop_domain(env[:org])
        env.update(ctx, 'shop', self.shop_domain) if env[:shop].nil?
      end

      private

      def ask_app(org)
        super(org['apps'], api_key, message: ctx.message('script.forms.enable.ask_app'))
      end

      def ask_shop_domain(org)
        super(org, message: ctx.message('script.forms.enable.ask_shop_domain'))
      end

      def ask_org
        organization(api_key)
      end
    end
  end
end
