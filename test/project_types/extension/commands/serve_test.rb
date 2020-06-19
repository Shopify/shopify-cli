# frozen_string_literal: true
require 'test_helper'

module Extension
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      class FakeProcessStatus
        def initialize(success)
          @success = success
        end

        def success?
          @success
        end
      end

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_implements_help
        refute_empty(Serve.help)
      end

      def test_uses_npm_when_yarn_is_unavailable
        Serve.any_instance.stubs(:yarn_available?).returns(false)
        @context.expects(:system).with(*Serve::NPM_SERVE_COMMAND).returns(FakeProcessStatus.new(true))

        # run_serve
        run_cmd('serve')
      end

      def test_aborts_and_informs_the_user_when_serve_fails
        Serve.any_instance.stubs(:yarn_available?).returns(true)
        @context.expects(:system).with(*Serve::YARN_SERVE_COMMAND).returns(FakeProcessStatus.new(false))
        @context.expects(:abort).with(@context.message('serve.serve_failure_message'))

        run_serve
      end

      private

      def run_serve(*args)
        Serve.ctx = @context
        Serve.call(args, 'serve')
      end
    end
  end
end
