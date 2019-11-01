require 'test_helper'

module ShopifyCli
  module Helpers
    class GitTest < MiniTest::Test
      def test_sha_shortcut
        fake_sha = ('c0ffee' * 6) + 'dead'
        in_repo do |_dir|
          File.write('.git/HEAD', fake_sha)

          assert_equal(fake_sha, Git.sha)
        end
      end

      def test_head_sha
        in_repo do |_dir|
          empty_commit
          refute_nil(Git.sha)
        end
      end

      private

      def in_repo
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            system('git init > /dev/null')
            yield(dir)
          end
        end
      end

      def empty_commit
        Git.exec('commit', '-m', 'commit', '--allow-empty')
      end
    end
  end
end
