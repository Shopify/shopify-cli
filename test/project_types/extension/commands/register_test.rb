# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Commands
    class RegisterTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TempProjectSetup
      include ExtensionTestHelpers::Messages
      include ExtensionTestHelpers::Stubs::GetApp

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
        setup_temp_project(api_key: '', api_secret: '', registration_id: nil)

        @app = Models::App.new(api_key: @api_key, secret: @api_secret)
        stub_get_app(app: @app, api_key: @app.api_key)
      end

      def test_help_implemented
        assert_nothing_raised { refute_nil Commands::Register.help }
      end

      def test_if_extension_is_already_registered_the_register_command_aborts
        @project.expects(:registered?).returns(true).once
        Tasks::CreateExtension.any_instance.expects(:call).never
        ExtensionProject.expects(:write_env_file).never

        io = capture_io_and_assert_raises(ShopifyCli::Abort) { run_register_command }

        assert_message_output(io: io, expected_content: @context.message('register.already_registered'))
      end

      def test_does_not_run_create_if_user_does_not_confirm
        refute @project.registered?
        Tasks::CreateExtension.any_instance.expects(:call).never
        ExtensionProject.expects(:write_env_file).never

        CLI::UI::Prompt
          .expects(:confirm)
          .with(@context.message('register.confirm_question', @app.title))
          .returns(false)
          .once

        io = capture_io_and_assert_raises(ShopifyCli::AbortSilent) { run_register_command }

        assert_message_output(io: io, expected_content: [
          @context.message('register.confirm_abort'),
          @context.message('register.confirm_info', @test_extension_type.name),
        ])
      end

      def test_creates_the_extension_if_user_confirms
        registration = Models::Registration.new(
          id: 55,
          type: @test_extension_type.identifier,
          title: @project.title,
          draft_version: Models::Version.new(
            registration_id: 55,
            last_user_interaction_at: Time.now.utc,
          )

        )
        refute @project.registered?

        CLI::UI::Prompt
          .expects(:confirm)
          .with(@context.message('register.confirm_question', @app.title))
          .returns(true)
          .once

        Tasks::CreateExtension.any_instance.expects(:call).with(
          context: @context,
          api_key: @app.api_key,
          type: @test_extension_type.graphql_identifier,
          title: @project.title,
          config: {},
          extension_context: @test_extension_type.extension_context(@context)
        ).returns(registration).once

        ExtensionProject.expects(:write_env_file).with(
          context: @context,
          api_key: @app.api_key,
          api_secret: @app.secret,
          registration_id: registration.id,
          title: @project.title
        ).once

        io = capture_io { run_register_command }

        assert_message_output(io: io, expected_content: [
          @context.message('register.confirm_info', @test_extension_type.name),
          @context.message('register.waiting_text'),
          @context.message('register.success', @project.title, @app.title),
          @context.message('register.success_info'),
        ])
      end

      private

      def run_register_command(api_key: @api_key)
        Commands::Register.ctx = @context
        Commands::Register.call(
          %W(--api_key=#{api_key}),
          :register
        )
      end
    end
  end
end
