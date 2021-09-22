# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class RegisterTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call)
        @project = ExtensionTestHelpers.fake_extension_project(with_mocks: true, registration_id: nil)
        @specification_handler = ExtensionTestHelpers.test_specification_handler

        @app = Models::App.new(api_key: @project.api_key, secret: @project.api_secret)
      end

      def test_help_implemented
        assert_nothing_raised { refute_nil Command::Register.help }
      end

      def test_if_extension_is_already_registered_the_register_command_aborts
        # skip("Need to revisit processing of arguments to subcommands")
        @project.expects(:registered?).returns(true).once
        Tasks::CreateExtension.any_instance.expects(:call).never
        ExtensionProject.expects(:write_env_file).never

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) { run_register_command }

        assert_message_output(io: io, expected_content: @context.message("register.already_registered"))
      end

      def test_does_not_run_create_if_user_does_not_confirm
        refute @project.registered?
        Tasks::CreateExtension.any_instance.expects(:call).never
        ExtensionProject.expects(:write_env_file).never

        CLI::UI::Prompt
          .expects(:confirm)
          .with(@context.message("register.confirm_question"))
          .returns(false)
          .once

        io = capture_io_and_assert_raises(ShopifyCLI::AbortSilent) { run_register_command }

        assert_message_output(io: io, expected_content: [
          @context.message("register.confirm_abort"),
          @context.message("register.confirm_info", @specification_handler.name),
        ])
      end

      def test_creates_the_extension_if_user_confirms
        registration = Models::Registration.new(
          id: 55,
          uuid: "123",
          type: @specification_handler.identifier,
          title: @project.title,
          draft_version: Models::Version.new(
            registration_id: 55,
            last_user_interaction_at: Time.now.utc,
          )
        )
        refute @project.registered?

        CLI::UI::Prompt
          .expects(:confirm)
          .with(@context.message("register.confirm_question", @app.title))
          .returns(true)
          .once

        Tasks::CreateExtension.any_instance.expects(:call).with(
          context: @context,
          api_key: @app.api_key,
          type: @specification_handler.graphql_identifier,
          title: @project.title,
          config: {},
          extension_context: @specification_handler.extension_context(@context)
        ).returns(registration).once

        ExtensionProject.expects(:write_env_file).with(
          context: @context,
          api_key: @app.api_key,
          api_secret: @app.secret,
          registration_id: registration.id,
          registration_uuid: registration.uuid,
          title: @project.title
        ).once

        io = capture_io { run_register_command }

        assert_message_output(io: io, expected_content: [
          @context.message("register.confirm_info", @specification_handler.name),
          @context.message("register.waiting_text"),
          @context.message("register.success", @project.title),
          @context.message("register.success_info"),
        ])
      end

      private

      def run_register_command
        run_cmd("extension register")
      end
    end
  end
end
