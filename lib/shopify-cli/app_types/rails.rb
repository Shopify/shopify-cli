# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Rails < AppType
      include ShopifyCli::Helpers

      class << self
        def description
          'rails embedded app'
        end

        def generate
          {
            page: NotImplementedError,
            billing_recurring: NotImplementedError,
            billing_one_time: NotImplementedError,
            webhook: 'rails g shopify_app:add_webhook',
          }
        end

        def generate_command(selected_type)
          parts = selected_type.downcase.split("_")
          selected_type = parts[0..-2].join("_") + "/" + parts[-1]
          "#{generate[:webhook]} -t #{selected_type} -a #{Project.current.env.host}/webhooks/#{selected_type.downcase}"
        end

        def webhook_location
          " config/initializers/shopify_app.rb"
        end

        def callback_url
          "/auth/shopify/callback"
        end
      end
    end
  end
end
