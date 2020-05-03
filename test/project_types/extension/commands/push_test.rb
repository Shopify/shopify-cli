# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Commands
    class PushTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TempProjectSetup
      include ExtensionTestHelpers::Content

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
        setup_temp_project

        @registration = Models::Registration.new(
          id: 42,
          type: @type.identifier,
          title: @title
        )
      end

      def test_help_implemented
        assert_nothing_raised do
          refute_nil Commands::Push.help
        end
      end

      def test_does_not_run_create_if_user_does_not_confirm
        Commands::Pack.any_instance.expects(:call).once
        Tasks::UpdateDraft.expects(:call).never
        Tasks::CreateExtension.expects(:call).never

        @context.expects(:abort).with(Content::Push::CREATE_ABORT).once

        CLI::UI::Prompt
          .expects(:confirm)
          .with(Content::Push::CREATE_CONFIRM_QUESTION)
          .returns(false).once

        capture_io { run_push }.join
      end

      def test_runs_create_if_no_registration_id_is_present_and_user_confirms_then_sets_registration_id
        refute @project.registration_id?
        Commands::Pack.any_instance.expects(:call).once
        Tasks::UpdateDraft.expects(:call).never

        CLI::UI::Prompt
          .expects(:confirm)
          .with(Content::Push::CREATE_CONFIRM_QUESTION)
          .returns(true).once

        Tasks::CreateExtension.expects(:call)
          .with(
            context: @context,
            api_key: @api_key,
            type: @type.identifier,
            title: @title,
            config: @type.config(@context),
            extension_context: @type.extension_context(@context)
          )
          .returns(@registration).once

        io = capture_io { run_push }

        assert_equal @registration.id, @project.registration_id
        confirm_content_output(io: io, expected_content: [
          Content::Push::WAITING_TEXT,
          Content::Push::SUCCESS_CONFIRMATION % @title,
          Content::Push::SUCCESS_INFO
        ])
      end

      def test_runs_update_if_registration_id_is_present
        @project.set_registration_id(@context, @registration.id)
        Commands::Pack.any_instance.expects(:call).once
        Tasks::CreateExtension.expects(:call).never

        Tasks::UpdateDraft.any_instance.expects(:call).with(
          context: @context,
          api_key: @api_key,
          registration_id: @registration.id,
          config: @type.config(@context),
          extension_context: @type.extension_context(@context)
        ).once

        io = capture_io { run_push }

        confirm_content_output(io: io, expected_content: [
          Content::Push::WAITING_TEXT,
          Content::Push::SUCCESS_CONFIRMATION % @title,
          Content::Push::SUCCESS_INFO
        ])
      end

      def run_push
        push_command = Commands::Push.new
        push_command.ctx = @context
        push_command.call({}, :push)
      end
    end
  end
end
