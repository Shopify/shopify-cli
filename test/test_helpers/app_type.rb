module TestHelpers
  module AppType
    class FakeAppType < ShopifyCli::AppTypes::AppType
      class << self
        def env_file
          <<~ENV
            API_KEY={api_key}
            SECRET={secret}
            HOST={host}
            SHOP={shop}
          ENV
        end

        def description; end

        def serve_command(_ctx)
          "a command"
        end

        def generate_command(_ctx)
          "a command"
        end

        def generate
          {
            empty_state: 'generate-app empty-state-page',
            two_column: 'generate-app two-column-page',
            annotated: 'generate-app settings-page',
            list: 'generate-app list-page',
            billing_recurring: 'generate-recurring-billing',
            billing_one_time: 'generate-one-time-billing',
            webhook: 'generate-webhook',
          }
        end

        def page_types
          {
            'empty-state' => :empty_state,
            'list' => :list,
            'two-column' => :two_column,
            'annotated' => :annotated,
          }
        end

        def open_url
          'https://example.com'
        end

        def webhook_location
          "im fake"
        end

        def callback_url
          "/callback/fake"
        end
      end
    end

    def setup
      super
      ShopifyCli::AppTypeRegistry.register(:fake, FakeAppType)
    end

    def teardown
      ShopifyCli::AppTypeRegistry.deregister(:fake)
      super
    end
  end
end
