# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class CreateTest < MiniTest::Test
      include ExtensionTestHelpers::Stubs::GetApp

      def setup
        super
        @name = "My Ext"
        @directory_name = "my_ext"

        ShopifyCLI::ProjectType.load_type(:extension)

        ExtensionTestHelpers.fake_extension_project(with_mocks: true)
        @specification_handler = ExtensionTestHelpers.test_specification_handler

        @app = Models::App.new(title: "Fake", api_key: "1234", secret: "4567", business_name: "Fake Business")
        stub_get_app(api_key: "1234", app: @app)

        ShopifyCLI::Tasks::EnsureAuthenticated.stubs(:call)
      end

      def test_prints_help
        io = capture_io { run_cmd("extension create --help") }
        assert_message_output(io: io, expected_content: [Extension::Command::Create.help])
      end

      def test_create_aborts_if_the_directory_already_exists
        ShopifyCLI::Shopifolk.stubs(:check).returns(false)
        ShopifyCLI::Feature.stubs(:enabled?).with(:extension_server_beta).returns(false)

        Dir.expects(:exist?).with(@directory_name).returns(true).once
        Models::SpecificationHandlers::Default.any_instance.expects(:create).never

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          run_create(%W(extension --name=#{@name} --type=#{@specification_handler.identifier}
                        --api-key=#{@app.api_key}))
        end

        assert_message_output(io: io, expected_content: [
          @context.message("create.errors.directory_exists", @directory_name),
        ])
      end

      def test_runs_type_create_and_writes_project_files
        ShopifyCLI::Shopifolk.stubs(:check).returns(false)
        ShopifyCLI::Feature.stubs(:enabled?).with(:extension_server_beta).returns(false)

        Dir.expects(:exist?).with(@directory_name).returns(false).once
        Models::SpecificationHandlers::Default
          .any_instance.expects(:create).with(@directory_name, @context, getting_started: nil)
          .returns(true).once
        ExtensionProject.expects(:write_cli_file).with(context: @context, type: @specification_handler.identifier).once
        ExtensionProject
          .expects(:write_env_file)
          .with(context: @context, title: @name, api_key: @app.api_key, api_secret: @app.secret)
          .once

        io = capture_io do
          run_create(%W(extension --name=#{@name} --type=#{@specification_handler.identifier}
                        --api-key=#{@app.api_key}))
        end

        assert_message_output(io: io, expected_content: [
          @context.message("create.ready_to_start", @directory_name, @name),
          @context.message("create.learn_more", @specification_handler.name),
        ])
      end

      def test_does_not_create_project_files_and_outputs_try_again_message_if_type_create_failed
        ShopifyCLI::Shopifolk.stubs(:check).returns(false)
        ShopifyCLI::Feature.stubs(:enabled?).with(:extension_server_beta).returns(false)

        Dir.expects(:exist?).with(@directory_name).returns(false).once
        Models::SpecificationHandlers::Default
          .any_instance.expects(:create).with(@directory_name, @context, getting_started: nil)
          .returns(false).once
        ExtensionProject.expects(:write_cli_file).never
        ExtensionProject.expects(:write_env_file).never

        io = capture_io do
          run_create(%W(extension --name=#{@name} --type=#{@specification_handler.identifier}
                        --api-key=#{@app.api_key}))
        end

        assert_message_output(io: io, expected_content: @context.message("create.try_again"))
      end

      private

      def run_create(arguments)
        specifications = ExtensionTestHelpers.test_specifications
        Models::Specifications.stubs(:new).returns(specifications)
        Extension::Command::Create.ctx = @context
        Extension::Command::Create.call(arguments, "create", "create")
      end
    end
  end
end
