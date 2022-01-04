# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_nothing_is_raised_if_node_version_meets_minimum_major_and_minor_versions
        mock_node_version("v10.11.12")
        assert_nothing_raised(ShopifyCLI::Abort) do
          ArgoDependencies.node_installed(min_major: 10, min_minor: 11).call(@context)
        end

        mock_node_version("v10.11.12")
        assert_nothing_raised(ShopifyCLI::Abort) do
          ArgoDependencies.node_installed(min_major: 9, min_minor: 11).call(@context)
        end

        mock_node_version("v10.11.12")
        assert_nothing_raised(ShopifyCLI::Abort) do
          ArgoDependencies.node_installed(min_major: 10, min_minor: 10).call(@context)
        end
      end

      def test_if_node_version_command_fails_abort_with_missing_node_message
        mock_node_version("", success: false)

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          ArgoDependencies.node_installed(min_major: 11).call(@context)
        end

        assert_message_output(io: io, expected_content: [
          @context.message("features.argo.dependencies.node.node_not_installed"),
        ])
      end

      def test_if_node_exists_but_major_version_is_under_the_minimum_abort_with_message
        mock_node_version("v10.11.12")

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          ArgoDependencies.node_installed(min_major: 11).call(@context)
        end

        assert_message_output(io: io, expected_content: [
          @context.message("features.argo.dependencies.node.version_too_low", "v10.11.12", "v11.x.x"),
        ])
      end

      def test_if_major_version_is_the_minimum_version_abort_with_message_if_minor_version_is_under_the_minimum_version
        mock_node_version("v10.11.12")

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          ArgoDependencies.node_installed(min_major: 10, min_minor: 12).call(@context)
        end

        assert_message_output(io: io, expected_content: [
          @context.message("features.argo.dependencies.node.version_too_low", "v10.11.12", "v10.12.x"),
        ])
      end

      def test_if_major_version_is_the_above_the_minimum_version_do_not_check_minor_version
        mock_node_version("v13.7.0")

        assert_nothing_raised do
          ArgoDependencies.node_installed(min_major: 10, min_minor: 13).call(@context)
        end
      end

      private

      def mock_node_version(version, success: true)
        CLI::Kit::System
          .expects(:capture2)
          .returns([version, mock(success?: success)])
          .once
      end
    end
  end
end
