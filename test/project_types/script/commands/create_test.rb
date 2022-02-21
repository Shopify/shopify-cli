# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include TestHelpers::FakeFS
      include TestHelpers::Command

      def setup
        super
        ShopifyCLI::Core::Monorail.stubs(:log).yields
        @context = TestHelpers::FakeContext.new
        @language = "assemblyscript"
        @script_name = "name"
        @ep_type = "discount"
        @script_project = TestHelpers::FakeScriptProjectRepository.new.create(
          language: @language,
          extension_point_type: @ep_type,
          script_name: @script_name
        )
        @branch = "master"
        Layers::Application::ExtensionPoints.stubs(:languages).returns(%w(assemblyscript))
        ShopifyCLI::Tasks::EnsureAuthenticated.stubs(:call)
      end

      def test_prints_help_with_no_name_argument
        root = File.expand_path(__dir__ + "../../../../..")
        FakeFS::FileSystem.clone(root + "/lib/project_types/script/config/extension_points.yml")
        @script_name = nil
        io = capture_io { perform_command(name: @script_name, api: @ep_type, language: @language, branch: @branch) }
        assert_match(CLI::UI.fmt(Script::Command::Create.help), io.join)
      end

      def test_defaults_to_wasm
        Script::Layers::Application::CreateScript.expects(:call).with(
          ctx: @context,
          language: "wasm",
          sparse_checkout_branch: @branch,
          script_name: @script_name,
          extension_point_type: @ep_type,
        ).returns(@script_project)

        perform_command(name: @script_name, api: @ep_type, branch: @branch)
      end

      def test_downcases_language
        @language = "TypeScript"
        Script::Layers::Application::CreateScript.expects(:call).with(
          ctx: @context,
          language: @language.downcase,
          sparse_checkout_branch: @branch,
          script_name: @script_name,
          extension_point_type: @ep_type,
        ).returns(@script_project)

        perform_command(name: @script_name, api: @ep_type, language: @language, branch: @branch)
      end

      def test_can_create_new_script
        Script::Layers::Application::CreateScript.expects(:call).with(
          ctx: @context,
          language: @language,
          sparse_checkout_branch: @branch,
          script_name: @script_name,
          extension_point_type: @ep_type,
        ).returns(@script_project)

        @context
          .expects(:puts)
          .with(@context.message("script.create.change_directory_notice", @script_project.script_name))
        perform_command(name: @script_name, api: @ep_type, language: @language, branch: @branch)
      end

      def test_help
        Script::Layers::Application::ExtensionPoints.expects(:available_types).returns(%w(ep1 ep2))
        Script::Layers::Application::ExtensionPoints.expects(:all_languages).returns(%w(lang1 lang2))
        ShopifyCLI::Context.expects(:message).with(
          "script.create.help",
          ShopifyCLI::TOOL_NAME,
          "{{cyan:ep1}}, {{cyan:ep2}}",
          "{{cyan:lang1}}, {{cyan:lang2}}"
        )
        Script::Command::Create.help
      end

      private

      def perform_command(args)
        run_cmd("script create #{args.map { |k, v| "--#{k}=#{v}" }.join(" ")}")
      end
    end
  end
end
