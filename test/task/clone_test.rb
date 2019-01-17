require 'test_helper'

module ShopifyCli
  module Tasks
    class CloneTest < MiniTest::Test
      def test_clones_git_repo
        CLI::Kit::System.expects(:system).with(
          'git',
          'clone',
          '--single-branch',
          'git@github.com:shopify/test.git',
          'test-app',
          '--progress'
        ).returns(mock(:success? => true))
        io = capture_io do
          ShopifyCli::Tasks::Clone.call('git@github.com:shopify/test.git', 'test-app')
        end
        output = io.join
        assert_match('Cloning into test-app...', output)
      end
    end
  end
end
