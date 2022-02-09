# frozen_string_literal: true

require "project_types/script/test_helper"
require_relative "../../../../ext/javy/javy.rb"

module Script
  module Commands
    class JavyTest < MiniTest::Test
      include TestHelpers::FakeUI
      include TestHelpers::FakeFS
      include TestHelpers::Command

      def setup
        super
        @context = TestHelpers::FakeContext.new
      end

      def test_calls_javy_and_succeeds
        in_filename = "build/index.js"
        out_filename = "build/script.wasm"

        stub_build_success(source: in_filename, dest: out_filename)

        capture_io do
          run_cmd("script javy --in=#{in_filename} --out=#{out_filename}")
        end
      end

      def test_raises_error_when_javy_fails
        in_filename = "build/index.js"
        out_filename = "build/script.wasm"
        error = RuntimeError.new("whoops")

        stub_build_failure(source: in_filename, dest: out_filename, error: error)
        @context.expects(:abort).with(error.message)

        capture_io do
          run_cmd("script javy --in=#{in_filename} --out=#{out_filename}")
        end
      end

      def test_optionally_accepts_out_argument
        in_filename = "build/index.js"

        stub_build_success(source: in_filename, dest: nil)

        capture_io do
          run_cmd("script javy --in=#{in_filename}")
        end
      end

      def test_invalid_args_fails
        error = assert_raises(ShopifyCLI::Abort) do
          capture_io { run_cmd("script javy") }
        end

        assert_match(@context.message("script.javy.errors.invalid_arguments", ShopifyCLI::TOOL_NAME), error.message)
      end

      def test_help
        assert_includes(Script::Command::Javy.help, "script javy")
      end

      private

      def stub_build_success(source:, dest:)
        Javy
          .expects(:build)
          .with(source: source, dest: dest)
          .returns(ShopifyCLI::Result.success(true))
      end

      def stub_build_failure(source:, dest:, error:)
        Javy
          .expects(:build)
          .with(source: source, dest: dest)
          .returns(ShopifyCLI::Result.failure(error))
      end
    end
  end
end
