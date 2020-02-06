require 'test_helper'

module ShopifyCli
  module Tasks
    class CloneTest < MiniTest::Test
      def setup
        @app_dir = 'test-app'
        FileUtils.rm_rf(@app_dir) if Dir.exist?(@app_dir)
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
          ShopifyCli::Tasks::Clone.call('git@github.com:shopify/test.git', @app_dir)
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
            ShopifyCli::Tasks::Clone.call('git@github.com:shopify/test.git', @app_dir)
          end
        end
      end
    end
  end
end
