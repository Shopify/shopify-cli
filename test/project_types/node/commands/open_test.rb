# frozen_string_literal: true
require "project_types/node/test_helper"

module Node
  module Commands
    class OpenTest < MiniTest::Test
      def setup
        super
        project_context("app_types", "node")
        @context.stubs(:system)
      end

      def test_run
        @context.expects(:open_url!).with("https://example.com/auth?shop=my-test-shop.myshopify.com")
        Node::Command::Open.new(@context).call
      end
    end
  end
end
