module TestHelpers
  module AppType
    include TestHelpers::Context

    class FakeAppType < ShopifyCli::AppTypes::AppType
      class << self
        def env_file
          <<~ENV
            SHOPIFY_API_KEY={api_key}
            SHOPIFY_SECRET={secret}
            SHOPIFY_HOST={host}
          ENV
        end

        def description; end

        def serve_command(_ctx)
          "a command"
        end

        def generate
          {
            page: 'page-generate',
            billing: 'billing-generate',
          }
        end

        def open(ctx)
          ctx.system('open https://example.com')
        end
      end
    end

    def setup
      super
      ShopifyCli::AppTypeRegistry.register(:fake, FakeAppType)
      content = <<~CONTENT
        ---
        app_type: :fake
      CONTENT
      File.write(File.join(@context.root, '.shopify-cli.yml'), content)
    end

    def teardown
      ShopifyCli::AppTypeRegistry.deregister(:fake)
      super
    end
  end
end
