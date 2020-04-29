# frozen_string_literal: true
require 'test_helper'

module Extension
  module Commands
    class PackTest < MiniTest::Test
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
        assert Commands::Pack.hidden
      end

      def test_prints_help
        @context.expects(:puts).with(Extension::Commands::Pack.help)
        run_cmd('help pack')
      end

      def test_uses_yarn_when_yarn_is_available
        Pack.any_instance.stubs(:yarn_available?).returns(true)
        @context.expects(:system).with(*Pack::YARN_BUILD_COMMAND).returns(FakeProcessStatus.new(true))

        run_cmd('pack')
      end

      def test_uses_npm_when_yarn_is_unavailable
        Pack.any_instance.stubs(:yarn_available?).returns(false)
        @context.expects(:system).with(*Pack::NPM_BUILD_COMMAND).returns(FakeProcessStatus.new(true))

        run_cmd('pack')
      end

      def test_aborts_and_informs_the_user_when_build_fails
        Pack.any_instance.stubs(:yarn_available?).returns(true)
        @context.expects(:system).with(*Pack::YARN_BUILD_COMMAND).returns(FakeProcessStatus.new(false))
        @context.expects(:abort).with(Pack::BUILD_FAILURE_MESSAGE)

        run_cmd('pack')
      end
    end
  end
end
