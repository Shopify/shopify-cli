require 'test_helper'

module ShopifyCli
  module Tasks
    class CloneTest < MiniTest::Test
      def setup
        super
        no_project_context
      end

      def test_clones_git_repo
        CLI::Kit::System.expects(:system).with(
          'git',
          'clone',
          '--single-branch',
          'git@github.com:shopify/test.git',
          'test-app',
          '--progress'
        ).returns(mock(success?: true))
        capture_io do
          ShopifyCli::Tasks::Clone.call('git@github.com:shopify/test.git', 'test-app')
        end
      end

      def test_clone_failure
        assert_raises(ShopifyCli::Abort) do
          CLI::Kit::System.expects(:system).with(
            'git',
            'clone',
            '--single-branch',
            'git@github.com:shopify/test.git',
            'test-app',
            '--progress'
          ).returns(mock(success?: false))
          capture_io do
            ShopifyCli::Tasks::Clone.call('git@github.com:shopify/test.git', 'test-app')
          end
        end
      end
    end
  end
end
