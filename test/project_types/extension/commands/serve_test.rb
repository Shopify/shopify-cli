# frozen_string_literal: true
require "test_helper"

module Extension
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_implements_help
        refute_empty(Command::Serve.help)
      end

      def test_uses_js_system_to_run_npm_or_yarn_serve_commands
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: Command::Serve::YARN_SERVE_COMMAND, npm: Command::Serve::NPM_SERVE_COMMAND)
          .returns(true)
          .once

        run_serve
      end

      def test_aborts_and_informs_the_user_when_serve_fails
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: Command::Serve::YARN_SERVE_COMMAND, npm: Command::Serve::NPM_SERVE_COMMAND)
          .returns(false)
          .once
        @context.expects(:abort).with(@context.message("serve.serve_failure_message"))

        run_serve
      end

      private

      def run_serve(*args)
        run_cmd("extension serve " + args.join(" "))
      end
    end
  end
end
