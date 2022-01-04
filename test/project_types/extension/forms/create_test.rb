# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers
      include ExtensionTestHelpers::TestExtensionSetup
      include ExtensionTestHelpers::Stubs::GetApp

      attr_reader :app, :extension_handler

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
        @app = Models::App.new(title: "Fake", api_key: "1234", secret: "4567", business_name: "Fake Business")
        @extension_handler = ExtensionTestHelpers.test_specification_handler
      end

      def test_question_order
        call_order = []

        Questions::AskApp.expects(:new).returns(->(project_details) do
          call_order << :ask_app
          project_details.app = app
          project_details
        end)

        Questions::AskName.expects(:new).returns(->(project_details) do
          call_order << :ask_name
          project_details.name = "Test Extension"
          project_details
        end)

        Questions::AskType.expects(:new).returns(->(project_details) do
          call_order << :ask_type
          project_details.type = extension_handler
          project_details
        end)

        Questions::AskTemplate.expects(:new).returns(->(project_details) do
          call_order << :ask_template
          project_details.template = "javascript"
          project_details
        end)

        form = Create.ask(@context, [], {})
        assert_equal app, form.app
        assert_equal "Test Extension", form.name
        assert_equal extension_handler, form.type
        assert_equal "javascript", form.template
        assert_equal "test_extension", form.directory_name
        assert_equal [:ask_app, :ask_type, :ask_template, :ask_name], call_order
      end

      def test_command_line_argument_forwarding
        api_key = app.api_key
        identifier = "test-extension"
        name = "Test Extension"

        Questions::AskApp.expects(:new).with(ctx: @context, api_key: api_key).returns(->(project_details) do
          project_details.app = app
          project_details
        end)

        Questions::AskName.expects(:new).with(ctx: @context, name: name).returns(->(project_details) do
          project_details.name = "Test Extension"
          project_details
        end)

        Questions::AskType.expects(:new).with(ctx: @context, type: identifier).returns(->(project_details) do
          project_details.type = extension_handler
          project_details
        end)

        Questions::AskTemplate.expects(:new).with(ctx: @context, template: nil).returns(->(project_details) do
          project_details.template = "javascript"
          project_details
        end)

        Create.ask(
          @context,
          [],
          api_key: api_key,
          type: identifier,
          name: name
        )
      end
    end
  end
end
