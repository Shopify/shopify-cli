# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'
require 'base64'
require 'pathname'

module Extension
  module Features
    class ArgoTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::Stubs::ArgoScript

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)

        @git_template = 'https://www.github.com/fake_template.git'
        @argo = Argo.new(git_template: @git_template)
        @identifier = 'FAKE_ARGO_TYPE'
        @directory = 'fake_directory'
      end

      def test_create_clones_repo_then_initializes_project_then_cleans_up
        @argo.expects(:check_dependencies).with(@context).once
        @argo.expects(:clone_template).with(@directory, @context).once
        @argo.expects(:initialize_project).with(@identifier, @context).once
        @argo.expects(:cleanup).with(@context).once

        @argo.create(@directory, @identifier, @context)
      end

      def test_clone_template_clones_argo_template_git_repo_into_directory_and_updates_context_root
        ShopifyCli::Git.expects(:clone).with(@git_template, @directory, ctx: @context).once

        @argo.clone_template(@directory, @context)

        assert_equal @directory, Pathname(@context.root).each_filename.to_a.last
      end

      def test_initialize_project_installs_js_dependencies_and_requests_js_system_to_generate
        expected_npm_command = Argo::NPM_INITIALIZE_COMMAND + [Argo::INITIALIZE_TYPE_PARAMETER % @identifier]
        expected_yarn_command = Argo::YARN_INITIALIZE_COMMAND + [Argo::INITIALIZE_TYPE_PARAMETER % @identifier]

        ShopifyCli::JsDeps.any_instance.expects(:install).once
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: expected_yarn_command, npm: expected_npm_command)
          .once

        @argo.initialize_project(@identifier, @context)
      end

      def test_cleanup_removes_git_and_script_directories
        @context.expects(:rm_r).with(Argo::GIT_DIRECTORY).once
        @context.expects(:rm_r).with(Argo::SCRIPTS_DIRECTORY).once

        @argo.cleanup(@context)
      end

      def test_config_aborts_with_error_if_script_file_doesnt_exist
        error = assert_raises ShopifyCli::Abort do
          @argo.config(@context)
        end

        assert error.message.include?(@context.message('features.argo.missing_file_error'))
      end

      def test_config_aborts_with_error_if_script_serialization_fails
        File.stubs(:exists?).returns(true)
        Base64.stubs(:strict_encode64).raises(IOError)

        error = assert_raises(ShopifyCli::Abort) { @argo.config(@context) }
        assert error.message.include?(@context.message('features.argo.script_prepare_error'))
      end

      def test_config_aborts_with_error_if_file_read_fails
        File.stubs(:exists?).returns(true)
        File.any_instance.stubs(:read).raises(IOError)

        error = assert_raises(ShopifyCli::Abort) { @argo.config(@context) }
        assert error.message.include?(@context.message('features.argo.script_prepare_error'))
      end

      def test_config_encodes_script_into_context_if_it_exists
        with_stubbed_script(@context, Argo::SCRIPT_PATH) do
          config = @argo.config(@context)

          assert_equal [:serialized_script], config.keys
          assert_equal Base64.strict_encode64(TEMPLATE_SCRIPT.chomp), config[:serialized_script]
        end
      end

      def test_check_dependencies_loops_through_the_provided_dependencies
        execution_mock = Minitest::Mock.new
        execution_mock.expect(:executed, nil)

        test_proc = Proc.new do |context|
          execution_mock.executed
          assert_equal @context, context
        end

        Argo.new(git_template: @git_template, dependency_checks: [test_proc]).check_dependencies(@context)
        execution_mock.verify
      end

      def test_admin_method_returns_an_argo_extension_with_the_subscription_management_template
        git_admin_template = 'https://github.com/Shopify/shopify-app-extension-template.git'.freeze
        argo = Argo.admin
        assert_equal(argo.git_template, git_admin_template)
      end

      def test_checkout_method_returns_an_argo_extension_with_the_checkout_post_purchase_template
        git_checkout_template = 'https://github.com/Shopify/argo-checkout-template.git'.freeze
        argo = Argo.checkout
        assert_equal(argo.git_template, git_checkout_template)
      end
    end
  end
end
