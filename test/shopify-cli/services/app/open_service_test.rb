# typed: ignore
require "test_helper"

module ShopifyCLI
  module Services
    module App
      class ReportingServiceTest < MiniTest::Test
        def setup
          project_context("app_types", "php")
          @context.stubs(:system)
          super()
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
