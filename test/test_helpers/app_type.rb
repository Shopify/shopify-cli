module TestHelpers
  module AppType
    include TestHelpers::Context

    class FakeAppType < ShopifyCli::AppTypes::AppType
      def self.description; end

      def self.serve_command
        "a command"
      end

      def self.generate
        { page: 'page-generate',
          billing: 'billing-generate',
        }
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
