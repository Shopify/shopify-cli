# frozen_string_literal: true

require "project_types/script/test_helper"
require_relative "../../../../ext/javy/javy.rb"

module Script
  module Commands
    class JavyTest < MiniTest::Test
      include TestHelpers::FakeUI
      include TestHelpers::FakeFS

      def setup
        super
        @context = TestHelpers::FakeContext.new
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call).with(@context, :script).returns(true)
      end

      def test_calls_javy
        in_filename = "build/index.js"
        out_filename = "build/script.wasm"
        Javy.expects(:build).with(source: in_filename, dest: out_filename)
        capture_io do
          run_cmd("script javy --in=#{in_filename} --out=#{out_filename}")
        end
      end

      def test_invalid_args_fails
        error = assert_raises(ShopifyCLI::Abort) do
          capture_io { run_cmd("script javy") }
        end

        assert_match(@context.message("script.javy.errors.invalid_arguments", ShopifyCLI::TOOL_NAME), error.message)
      end

      def test_help
        ShopifyCLI::Context
          .expects(:message)
          .with("script.javy.help", ShopifyCLI::TOOL_NAME)
        Script::Command::Javy.help
      end
    end
  end
end
