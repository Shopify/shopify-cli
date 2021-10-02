# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"
require "base64"

module Extension
  module Features
    class ArgoTest < MiniTest::Test
      include ExtensionTestHelpers::Stubs::ArgoScript

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)

        @dummy_argo = ExtensionTestHelpers::DummyArgo.new(
          git_template: "dummy-template",
          renderer_package_name: "dummy-renderer",
        )
        @result = "fake result"
        @error_message = "fake error"
        @no_error = ""
        @encoded_script = Base64.strict_encode64("var fake={}")
      end

      def test_config_aborts_with_error_if_script_file_doesnt_exist
        File.stubs(:exist?).returns(false)
        stub_run_yarn_install_and_run_yarn_run_script_methods
        error = assert_raises ShopifyCLI::Abort do
          @dummy_argo.config(@context)
        end

        assert_includes error.message, @context.message("features.argo.missing_file_error")
      end

      def test_config_aborts_with_error_if_script_serialization_fails
        stub_run_yarn_install_and_run_yarn_run_script_methods
        File.stubs(:exist?).returns(true)
        Base64.stubs(:strict_encode64).raises(IOError)

        @dummy_argo.renderer_version = "0.0.1"
        error = assert_raises(ShopifyCLI::Abort) { @dummy_argo.config(@context) }
        assert_includes error.message, @context.message("features.argo.script_prepare_error")
      end

      def test_config_aborts_with_error_if_file_read_fails
        stub_run_yarn_install_and_run_yarn_run_script_methods
        File.stubs(:exist?).returns(true)
        File.any_instance.stubs(:read).raises(IOError)

        @dummy_argo.renderer_version = "0.0.1"

        error = assert_raises(ShopifyCLI::Abort) { @dummy_argo.config(@context) }
        assert_includes error.message, @context.message("features.argo.script_prepare_error")
      end

      def test_config_encodes_script_into_config_if_it_exists
        with_stubbed_script(@context, Argo::SCRIPT_PATH) do
          stub_run_yarn_install_and_run_yarn_run_script_methods

          @dummy_argo.renderer_version = "0.0.1"

          config = @dummy_argo.config(@context)

          assert_includes config.keys, :serialized_script
          assert_equal Base64.strict_encode64(TEMPLATE_SCRIPT.chomp), config[:serialized_script]
        end
      end

      def test_config_returns_argo_renderer_package_name_version_if_it_exists_using_yarn
        yarn_list_result = <<~YARN
          yarn list v1.22.5
          ├─ @fake-package@0.3.9
          └─ @shopify/admin-ui-extensions@0.3.8
          ✨  Done in 0.40s.
        YARN

        with_stubbed_script(@context, Features::Argo::SCRIPT_PATH) do
          stub_package_manager(yarn_list_result)
          stub_run_yarn_install_and_run_yarn_run_script_methods
          config = @dummy_argo.config(@context)

          assert_includes(config.keys, :renderer_version)
          assert_match(Semantic::Version::SemVerRegexp, config[:renderer_version])
          assert_equal("0.3.8", config[:renderer_version])
        end
      end

      def test_config_returns_argo_renderer_package_version_if_it_exists_using_npm
        npm_list_result = <<~NPM
          test-extension-template@0.1.0
          └─┬ @fake-package@0.4.3
            └── @shopify/admin-ui-extensions@0.4.3
            ✨  Done in 0.40s.
        NPM

        with_stubbed_script(@context, Features::Argo::SCRIPT_PATH) do
          stub_package_manager(npm_list_result)
          config = @dummy_argo.config(@context)

          assert_includes(config.keys, :renderer_version)
          assert_match(Semantic::Version::SemVerRegexp, config[:renderer_version])
          assert_equal("0.4.3", config[:renderer_version])
        end
      end

      def test_config_aborts_if_renderer_package_cannot_be_resolved
        Base64.stubs(:strict_encode64).returns(@encoded_script)
        with_stubbed_script(@context, Argo::SCRIPT_PATH) do
          stub_run_yarn_install_and_run_yarn_run_script_methods
          Tasks::FindNpmPackages.expects(:exactly_one_of).raises(Extension::PackageResolutionFailed)
          error = assert_raises(ShopifyCLI::Abort) { @dummy_argo.config(@context) }
          assert_includes error
            .message, @context.message(
              "features.argo.dependencies.argo_missing_renderer_package_error",
              @error_message
            )
        end
      end

      def test_config_aborts_with_error_when_argo_renderer_package_name_not_found
        package_manager_output = <<~NPM
          test-extension-template@0.1.0
          └─┬ @not-a-renderer-package@0.4.3
            ✨  Done in 0.40s.
        NPM

        with_stubbed_script(@context, Features::Argo::SCRIPT_PATH) do
          stub_package_manager(package_manager_output)
          stub_run_yarn_install_and_run_yarn_run_script_methods

          error_message = "'#{@dummy_argo.renderer_package_name}' not found."
          error = assert_raises(ShopifyCLI::Abort) { @dummy_argo.config(@context) }
          assert_includes error
            .message, @context.message(
              "features.argo.dependencies.argo_missing_renderer_package_error",
              error_message
            )
        end
      end

      def test_runs_yarn_install_and_yarn_run_script_if_the_package_manager_is_yarn
        with_stubbed_script(@context, Features::Argo::SCRIPT_PATH) do
          ShopifyCLI::JsSystem.any_instance.stubs(:package_manager).returns("yarn")
          Argo.any_instance.expects(:run_yarn_install).returns(true).once
          Argo.any_instance.expects(:run_yarn_run_script).returns(true).once
          @dummy_argo.renderer_version = "0.0.1"

          @dummy_argo.config(@context)
        end
      end

      def test_does_not_run_yarn_install_and_yarn_run_script_if_the_package_manager_is_npm
        with_stubbed_script(@context, Features::Argo::SCRIPT_PATH) do
          ShopifyCLI::JsSystem.any_instance.stubs(:package_manager).returns("npm")
          Argo.any_instance.expects(:run_yarn_install).never
          Argo.any_instance.expects(:run_yarn_run_script).never
          @dummy_argo.renderer_version = "0.0.1"

          @dummy_argo.config(@context)
        end
      end

      def test_aborts_with_error_if_yarn_install_command_fails
        with_stubbed_script(@context, Features::Argo::SCRIPT_PATH) do
          ShopifyCLI::JsSystem.any_instance.stubs(:package_manager).returns("yarn")
          ShopifyCLI::JsSystem.any_instance.stubs(:call).returns([@result, @error_message, mock(success?: false)])
          error = assert_raises(ShopifyCLI::Abort) { @dummy_argo.config(@context) }
          assert_includes error.message,
            @context.message("features.argo.dependencies.yarn_install_error", @error_message)
        end
      end

      def test_aborts_with_error_if_yarn_run_script_command_fails
        with_stubbed_script(@context, Features::Argo::SCRIPT_PATH) do
          ShopifyCLI::JsSystem.any_instance.stubs(:package_manager).returns("yarn")
          Argo.any_instance.stubs(:run_yarn_install).returns(true)
          ShopifyCLI::JsSystem.any_instance.stubs(:call).returns([@result, @error_message, mock(success?: false)])
          error = assert_raises(ShopifyCLI::Abort) { @dummy_argo.config(@context) }
          assert_includes error.message,
            @context.message("features.argo.dependencies.yarn_run_script_error", @error_message)
        end
      end

      private

      def stub_run_yarn_install_and_run_yarn_run_script_methods
        ShopifyCLI::JsSystem.any_instance.stubs(:package_manager).returns("yarn")
        Argo.any_instance.stubs(:run_yarn_install).returns(true)
        Argo.any_instance.stubs(:run_yarn_run_script).returns(true)
      end

      def stub_package_manager(package_manager_output)
        ShopifyCLI::JsSystem
          .new(ctx: @context)
          .tap { |js_system| js_system.stubs(call: [package_manager_output, nil, stub(success?: true)]) }
          .yield_self { |js_system| Tasks::FindNpmPackages.new(js_system: js_system) }
          .tap { |find_npm_packages_stub| Tasks::FindNpmPackages.expects(:new).returns(find_npm_packages_stub) }
      end
    end
  end
end
