require "test_helper"

module ShopifyCLI
  module Services
    module App
      class ReportingServiceTest < MiniTest::Test
        def setup
          super
          project_context("app_types", "php")

          File.stubs(:exist?).returns(true)
          File.stubs(:exist?).with(
            File.join(FIXTURE_DIR, "app_types", "php", Constants::Files::SHOPIFY_CLI_YML)
          ).returns(true)

          @context.stubs(:system)
        end

        def test_call
          ShopifyCLI::Context.any_instance.expects(:open_url!)
            .with("https://example.com/login?shop=my-test-shop.myshopify.com")
          run_cmd("app open")
        end
      end
    end
  end
end
