require 'test_helper'

module Node
  class JsDepsTest < MiniTest::Test
    def setup
      project_context('app_types', 'node')
      ShopifyCli::ProjectType.load_type(:node)
    end

    def test_installs_with_npm
      JsDeps.any_instance.stubs(:yarn?).returns(false)
      CLI::Kit::System.expects(:system).with(
        'npm', 'install', '--no-audit', '--no-optional', '--silent',
        env: @context.env,
        chdir: @context.root,
      )
      io = capture_io do
        JsDeps.install(@context)
      end
      output = io.join
      assert_match('Installing dependencies with npm...', output)
    end

    def test_installs_with_yarn
      JsDeps.any_instance.stubs(:yarn?).returns(true)
      CLI::Kit::System.expects(:system).with(
        'yarn', 'install', '--silent',
        chdir: @context.root
      ).returns(mock(success?: true))
      io = capture_io do
        JsDeps.install(@context)
      end
      output = io.join
      assert_match('Installing dependencies with yarn...', output)
    end
  end
end
