# frozen_string_literal: true
require 'test_helper'

module Extension
  module Commands
    class BuildTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      class FakeProcessStatus
        def initialize(success)
          @success = success
        end

        def success?
          @success
        end
      end

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_is_a_hidden_command
        assert Commands::Build.hidden
      end

      def test_prints_help
        @context.expects(:puts).with(Extension::Commands::Build.help)
        run_cmd('help build')
      end

      def test_uses_yarn_when_yarn_is_available
        Build.any_instance.stubs(:yarn_available?).returns(true)
        @context.expects(:system).with(*Build::YARN_BUILD_COMMAND).returns(FakeProcessStatus.new(true))

        run_cmd('build')
      end

      def test_uses_npm_when_yarn_is_unavailable
        Build.any_instance.stubs(:yarn_available?).returns(false)
        @context.expects(:system).with(*Build::NPM_BUILD_COMMAND).returns(FakeProcessStatus.new(true))

        run_cmd('build')
      end

      def test_aborts_and_informs_the_user_when_build_fails
        Build.any_instance.stubs(:yarn_available?).returns(true)
        @context.expects(:system).with(*Build::YARN_BUILD_COMMAND).returns(FakeProcessStatus.new(false))
        @context.expects(:abort).with(@context.message('build.build_failure_message'))

        run_cmd('build')
      end
    end
  end
end
