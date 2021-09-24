# frozen_string_literal: true
require "project_types/php/test_helper"

module PHP
  module Commands
    class OpenTest < MiniTest::Test
      def setup
        super
        project_context("app_types", "php")
        @context.stubs(:system)
      end

      def test_run
        ShopifyCLI::Context.any_instance.expects(:open_url!)
          .with("https://example.com/login?shop=my-test-shop.myshopify.com")
        run_cmd("app php open")
      end
    end
  end
end
