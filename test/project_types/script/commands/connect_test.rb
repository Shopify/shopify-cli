# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Commands
    class ConnectTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include TestHelpers::FakeFS
      include TestHelpers::Command

      def setup
        super
        ShopifyCLI::Core::Monorail.stubs(:log).yields
        @context = TestHelpers::FakeContext.new
        ShopifyCLI::Tasks::EnsureAuthenticated.stubs(:call)
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call).with(@context, :script).returns(true)
      end

      def test_calls_connect_app
        Script::Layers::Application::ConnectApp.expects(:call).with(ctx: @context, force: true)
        perform_command
      end

      def test_calls_error_handler_when_exception_is_raised
        Script::Layers::Application::ConnectApp.expects(:call).raises(StandardError)

        UI::ErrorHandler.expects(:pretty_print_and_raise).with do |_error, args|
          assert_equal args[:failed_op], @context.message("script.connect.error.operation_failed")
        end

        perform_command
      end

      private

      def perform_command
        run_cmd("script connect")
      end
    end
  end
end
