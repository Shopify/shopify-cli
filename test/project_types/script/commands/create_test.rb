# frozen_string_literal: true

require 'project_types/script/test_helper'
require "project_types/script/layers/infrastructure/fake_script_repository"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"

module Script
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      def setup
        @context = TestHelpers::FakeContext.new
        @language = 'ts'
        @script_name = 'name'
        @ep_type = 'discount'
      end

      def test_prints_help_with_no_name_argument
        @script_name = nil
        io = capture_io { perform_command }
        assert_match(CLI::UI.fmt(Script::Commands::Create.help), io.join)
      end

      def test_can_create_new_script
        Script::Layers::Application::CreateScript
          .expects(:call)
          .with(ctx: @context, language: @language, script_name: @script_name, extension_point_type: @ep_type)
          .returns(fake_script)

        @context
          .expects(:puts)
          .with(@context.message('script.create.changed_dir', folder: fake_script.name))
        @context
          .expects(:puts)
          .with(@context.message('script.create.script_created', script_id: fake_script.id))
        perform_command
      end

      def test_help
        ShopifyCli::Context
          .expects(:message)
          .with('script.create.help', ShopifyCli::TOOL_NAME)
        Script::Commands::Create.help
      end

      def test_extended_help
        Script::Layers::Application::ExtensionPoints.expects(:types).returns(%w(ep1 ep2))
        ShopifyCli::Context
          .expects(:message)
          .with('script.create.extended_help', ShopifyCli::TOOL_NAME, '{{cyan:ep1}}, {{cyan:ep2}}')
        Script::Commands::Create.extended_help
      end

      def test_cleanup_after_error
        Dir.mktmpdir(@script_name)
        Layers::Application::CreateScript.expects(:call).with(
          ctx: @context,
          language: @language,
          script_name: @script_name,
          extension_point_type: @ep_type
        ).raises(StandardError)

        ScriptProject.expects(:cleanup).with(
          ctx: @context,
          script_name: @script_name,
          root_dir: @context.root
        )

        assert_raises StandardError do
          capture_io do
            perform_command
          end
        end

        refute @context.exist?(@script_name)
      end

      private

      def perform_command
        run_cmd("create script --name=#{@script_name} --extension_point=#{@ep_type}")
      end

      def fake_script
        @fake_script ||= begin
           ep = Script::Layers::Infrastructure::FakeExtensionPointRepository.new.create_extension_point(@ep_type)
           Script::Layers::Infrastructure::FakeScriptRepository.new(ctx: @context).create_script(
             @language,
             ep,
             @script_name
           )
         end
      end
    end
  end
end
