# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include TestHelpers::FakeFS

      def setup
        super
        ShopifyCli::Core::Monorail.stubs(:log).yields
        @context = TestHelpers::FakeContext.new
        @language = "assemblyscript"
        @script_name = "name"
        @api = "discount"
        @no_config_ui = false
        @script_project = TestHelpers::FakeScriptProjectRepository.new.create(
          language: @language,
          extension_point_type: @api,
          script_name: @script_name,
          no_config_ui: @no_config_ui
        )
        Layers::Application::ExtensionPoints.stubs(:languages).returns(%w(assemblyscript))
      end

      def test_prints_help_with_no_name_argument
        root = File.expand_path(__dir__ + "../../../../..")
        FakeFS::FileSystem.clone(root + "/lib/project_types/script/config/extension_points.yml")
        @script_name = nil
        io = capture_io { perform_command }
        assert_match(CLI::UI.fmt(Script::Commands::Create.help), io.join)
      end

      def test_can_create_new_script
        Script::Layers::Application::CreateScript.expects(:call).with(
          ctx: @context,
          language: @language,
          script_name: @script_name,
          extension_point_type: @api,
          no_config_ui: @no_config_ui
        ).returns(@script_project)

        @context
          .expects(:puts)
          .with(@context.message("script.create.change_directory_notice", @script_project.script_name))
        perform_command
      end

      def test_can_create_new_script_with_no_config_ui
        @no_config_ui = true

        Script::Layers::Application::CreateScript.expects(:call).with(
          ctx: @context,
          language: @language,
          script_name: @script_name,
          extension_point_type: @api,
          no_config_ui: @no_config_ui
        ).returns(@script_project)

        @context
          .expects(:puts)
          .with(@context.message("script.create.change_directory_notice", @script_project.script_name))
        perform_command
      end

      def test_help
        Script::Layers::Application::ExtensionPoints.expects(:types).returns(%w(ep1 ep2))
        ShopifyCli::Context
          .expects(:message)
          .with("script.create.help", ShopifyCli::TOOL_NAME, "{{cyan:ep1}}, {{cyan:ep2}}")
        Script::Commands::Create.help
      end

      private

      def perform_command_snake_case
        args = {
          name: @script_name,
          extension_point: @api,
          language: @language,
        }

        run_cmd("create script #{args.map { |k, v| "--#{k}=#{v}" }.join(" ")}")
      end

      def perform_command
        run_cmd(
          "create script "\
            "--name=#{@script_name} "\
            "--api=#{@api} "\
            "--language=#{@language} "\
            "#{@no_config_ui ? "--no-config-ui" : ""}"
        )
      end
    end
  end
end
