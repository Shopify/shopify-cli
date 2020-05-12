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
      end

      def test_help_implemented
        assert_nothing_raised do
          refute_nil Commands::Push.help
        end
      end

      def test_runs_register_command_if_extension_not_yet_registered
        @project.expects(:registered?).returns(false).once
        Commands::Register.any_instance.expects(:call).once
        Commands::Pack.any_instance.expects(:call).once
        Tasks::UpdateDraft.any_instance.expects(:call).once

        run_push
      end

      def test_does_not_run_register_command_if_extension_already_registered
        assert @project.registered?

        Commands::Register.any_instance.expects(:call).never
        Commands::Pack.any_instance.expects(:call).once
        Tasks::UpdateDraft.any_instance.expects(:call).once

        run_push
      end

      def test_packs_and_updates_draft_if_extension_registered
        assert @project.registered?

        Commands::Pack.any_instance.expects(:call).once
        Tasks::UpdateDraft.any_instance.expects(:call).with(
          context: @context,
          api_key: @api_key,
          registration_id: @registration_id,
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
