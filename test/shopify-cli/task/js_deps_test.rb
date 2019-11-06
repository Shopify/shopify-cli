require 'test_helper'

module ShopifyCli
  module Tasks
    class JsDepsTest < MiniTest::Test
      def setup
        project_context('app_types', 'node')
      end

      def test_installs_with_npm
        ShopifyCli::Tasks::JsDeps.any_instance.stubs(:installer).returns(:npm)
        CLI::Kit::System.expects(:system).with(
          'npm', 'install', '--no-audit', '--no-optional', '--silent',
          chdir: @context.root,
        )
        io = capture_io do
          ShopifyCli::Tasks::JsDeps.call(@context)
        end
        output = io.join
        assert_match('Installing dependencies with npm...', output)
        assert_match('Installing 37 dependencies', output)
      end

      def test_installs_with_yarn
        ShopifyCli::Tasks::JsDeps.any_instance.stubs(:installer).returns(:yarn)
        CLI::Kit::System.expects(:system).with(
          'yarn', 'install', '--silent',
          chdir: @context.root
        ).returns(mock(success?: true))
        io = capture_io do
          ShopifyCli::Tasks::JsDeps.call(@context)
        end
        output = io.join
        assert_match('Installing dependencies with yarn...', output)
      end
    end
  end
end
