# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Commands
    class DeployTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TempProjectSetup

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
        setup_temp_project

        @registration = Models::Registration.new(
          id: 42,
          type: @type.identifier,
          title: 'Fake Registration'
        )
      end

      def test_prints_help
        io = capture_io { run_cmd('deploy --help') }
        assert_match(CLI::UI.fmt(Extension::Commands::Deploy.help), io.join)
      end

      def test_runs_create_if_no_registration_id_is_present_and_sets_registration_id
        Tasks::UpdateDraft.expects(:call).never
        Tasks::CreateExtension.expects(:call)
          .with(
            context: @context,
            api_key: @api_key,
            type: @type.identifier,
            title: 'Testing the CLI',
            config: @type.config(@context)
          )
          .returns(@registration).once

        run_cmd('deploy')
        assert_equal @registration.id, @project.registration_id
      end

      def test_runs_update_if_registration_id_is_present
        @project.set_registration_id(@context, @registration.id)
        Tasks::CreateExtension.expects(:call).never

        Tasks::UpdateDraft.any_instance.expects(:call).with(
          context: @context,
          api_key: @api_key,
          registration_id: @registration.id,
          config: @type.config(@context)
        ).once

        run_cmd('deploy')
      end
    end
  end
end
