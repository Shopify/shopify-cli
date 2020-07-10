# frozen_string_literal: true

module Script
  module Forms
    class Push < ScriptForm
      flag_arguments :api_key, :force

      def ask
        if ScriptProject.current.env.nil?
          org = ask_org
          app = ask_app(org)
          self.api_key = app['apiKey']
          write_env(JSON.generate(org), api_key, app['apiSecretKeys'].first['secret'], nil)
        else
          self.api_key ||= ScriptProject.current.env[:api_key]
        end
      end

      private

      def ask_app(org)
        super(org['apps'], api_key)
      end

      def ask_org
        organization(api_key)
      end
    end
  end
end
