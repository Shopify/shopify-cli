# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Commands
    class RegisterTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TempProjectSetup
      include ExtensionTestHelpers::Content
      include ExtensionTestHelpers::Stubs::GetOrganizations

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
        setup_temp_project(api_key: '', api_secret: '', registration_id: nil)

        @app = Models::App.new(api_key: @api_key, secret: @api_secret)
        stub_get_organizations([organization(name: "Organization One", apps: [@app])])
      end

      def test_help_implemented
        assert_nothing_raised { refute_nil Commands::Register.help }
      end

      def test_if_extension_is_already_registered_the_register_command_aborts
        @project.expects(:registered?).returns(true).once
        Tasks::CreateExtension.any_instance.expects(:call).never
        ExtensionProject.expects(:write_env_file).never

        io = capture_io_and_assert_raises(ShopifyCli::Abort) { run_register_command }

        confirm_content_output(io: io, expected_content: Content::Register::ALREADY_REGISTERED)
      end

      def test_does_not_run_create_if_user_does_not_confirm
        refute @project.registered?
        Tasks::CreateExtension.any_instance.expects(:call).never
        ExtensionProject.expects(:write_env_file).never

        CLI::UI::Prompt.expects(:confirm).with(Content::Register::CONFIRM_QUESTION).returns(false).once

        io = capture_io_and_assert_raises(ShopifyCli::Abort) { run_register_command }

        confirm_content_output(io: io, expected_content: [
          Content::Register::CONFIRM_ABORT,
          Content::Register::CONFIRM_INFO % @test_extension_type.name,
        ])
      end

      def test_creates_the_extension_if_user_confirms
        registration = Models::Registration.new(id: 55, type: @test_extension_type.identifier, title: @project.title)
        refute @project.registered?

        CLI::UI::Prompt.expects(:confirm).with(Content::Register::CONFIRM_QUESTION).returns(true).once
        Tasks::CreateExtension.any_instance.expects(:call).with(
          context: @context,
          api_key: @app.api_key,
          type: @test_extension_type.identifier,
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

        confirm_content_output(io: io, expected_content: [
          Content::Register::CONFIRM_INFO % @test_extension_type.name,
          Content::Register::WAITING_TEXT,
          Content::Register::SUCCESS % @project.title,
          Content::Register::SUCCESS_INFO,
        ])
      end

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
