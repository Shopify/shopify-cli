# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class OpenTest < MiniTest::Test
      def setup
        super
        project_context("app_types", "rails")
        @context.stubs(:system)
      end

      def test_run
        @context.expects(:open_url!).with("https://example.com/login?shop=my-test-shop.myshopify.com")
        Rails::Command::Open.new(@context).call
      end
    end
  end
end
