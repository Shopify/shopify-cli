# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class ExtensionCommandTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
        @project = ExtensionTestHelpers.fake_extension_project(with_mocks: true)
        @command = Extension::Command::ExtensionCommand.new
      end

      def test_project_returns_the_current_extension_project
        assert_equal @project, @command.project
      end

      def test_project_memoizes_the_current_extension_project
        ExtensionProject.expects(:current).returns(@project).once

        @command.project
        @command.project
      end

      def test_extension_command_aborts_if_a_lazily_initialized_field_of_an_unknown_type_is_accessed
        unknown_type = "unknown_type"
        ExtensionTestHelpers.fake_extension_project(with_mocks: true, type_identifier: unknown_type)

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) { @command.specification_handler.features }

        assert_message_output(io: io, expected_content: [
          @context.message("errors.unknown_type", unknown_type),
        ])
      end

      def test_extension_command_returns_a_lazy_specification_handler
        assert_kind_of(Models::LazySpecificationHandler, @command.specification_handler)
      end

      def test_extension_command_memoizes_the_extension_type
        @command.specification_handler.specification
        @command.specification_handler.specification
      end

      def test_accessing_the_extension_type_identifier_does_not_result_in_fetching_specifications
        @command.specification_handler.identifier
      end
    end
  end
end
