# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class BuildTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call)
      end

      def test_is_a_hidden_command
        assert Command::Build.hidden?
      end

      def test_implements_help
        refute_empty(Extension::Command::Build.help)
      end

      def test_uses_js_system_to_call_yarn_or_npm_commands
        stub_project
        ShopifyCLI::JsSystem.any_instance
          .expects(:call)
          .with(yarn: Command::Build::YARN_BUILD_COMMAND, npm: Command::Build::NPM_BUILD_COMMAND)
          .returns(true)
          .once

        run_build
      end

      def test_aborts_and_informs_the_user_when_build_fails
        stub_project
        ShopifyCLI::JsSystem.any_instance.stubs(:call).returns(false)
        @context.expects(:abort).with(@context.message("build.build_failure_message"))

        run_build
      end

      def test_runs_new_flow_if_development_server_supported
        type = "checkout_ui_extension"
        stub_project(type)
        ShopifyCLI::Shopifolk.stubs(:check).returns(true)
        ShopifyCLI::Feature.stubs(:enabled?).with(:extension_server_beta).returns(true)
        File.stubs(:exist?).returns(true)

        extension_command = Tasks::RunExtensionCommand.new(type: type, command: "build")
        Extension::Tasks::RunExtensionCommand.expects(:new).returns(extension_command) do |mock|
          mock.expects(:call)
        end

        Models::ServerConfig::Extension.expects(:build)
          .with(template: nil, type: type, root_dir: nil)
          .returns(extension)

        server_config = Models::ServerConfig::Root.new(extensions: [extension])
        Models::ServerConfig::Root.expects(:new).returns(server_config)

        development_server = Models::DevelopmentServer.new(executable: "fake")
        Models::DevelopmentServer.expects(:new).returns(development_server) do |mock|
          mock.expects(:build)
        end

        CLI::Kit::System.expects(:capture3)
          .with(development_server.executable, "build", "-", stdin_data: server_config.to_yaml)
          .returns(["", nil, mock(success?: true)])

        run_build
      end

      private

      def run_build(*args)
        run_cmd("extension build " + args.join(" "))
      end

      def stub_project(type = "TEST")
        project = ExtensionTestHelpers.fake_extension_project(type_identifier: type)
        ShopifyCLI::Project.stubs(:current).returns(project)
      end

      def extension
        @extension ||= Models::ServerConfig::Extension.new(
          type: "checkout_ui_extension",
          uuid: "00000000-0000-0000-0000-000000000000",
          user: Models::ServerConfig::User.new,
          development: Models::ServerConfig::Development.new(build_dir: "test")
        )
      end
    end
  end
end
