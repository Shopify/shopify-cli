# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Commands
    class ExtensionCommandTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::Messages
      include ExtensionTestHelpers::TempProjectSetup

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
        @command = ExtensionCommand.new
      end

      def test_project_returns_the_current_extension_project
        setup_temp_project

        assert_equal @project, @command.project
      end

      def test_project_memoizes_the_current_extension_project
        setup_temp_project
        ExtensionProject.expects(:current).returns(@project).once

        @command.project
        @command.project
      end

      def test_extension_type_aborts_if_the_type_is_unknown
        unknown_type = 'unknown_type'
        setup_temp_project(type_identifier: unknown_type)

        io = capture_io_and_assert_raises(ShopifyCli::Abort) { @command.extension_type }

        assert_message_output(io: io, expected_content: [
          @context.message('errors.unknown_type', unknown_type),
        ])
      end

      def test_extension_type_returns_the_extension_type_instance_if_it_exists
        setup_temp_project

        assert_equal @test_extension_type, @command.extension_type
      end

      def test_extension_type_memoizes_the_extension_type
        setup_temp_project
        Extension.specifications.expects(:[]).returns(@test_extension_type).once

        @command.extension_type
        @command.extension_type
      end
    end
  end
end
