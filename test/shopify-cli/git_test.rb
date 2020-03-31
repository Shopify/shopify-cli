require 'test_helper'

module ShopifyCli
  class GitTest < MiniTest::Test
    def setup
      super

      @status_mock = {
        false: mock,
        true: mock,
      }
      @status_mock[:false].stubs(:success?).returns(false)
      @status_mock[:true].stubs(:success?).returns(true)
    end

    def test_branches_returns_master_if_no_branches_exist
      @context.expects(:capture2e)
        .with('git', 'branch', '--list', '--format=%(refname:short)')
        .returns(['', @status_mock[:true]])

      git_service = ShopifyCli::Git.new(@context)

      assert_equal(['master'], git_service.branches)
    end

    def test_branches_returns_list_of_branches_if_multiple_exist
      @context.expects(:capture2e)
        .with('git', 'branch', '--list', '--format=%(refname:short)')
        .returns(["master\nsecond_branch\n", @status_mock[:true]])

      git_service = ShopifyCli::Git.new(@context)

      assert_equal(['master', 'second_branch'], git_service.branches)
    end

    def test_branches_raises_if_finding_branches_fails
      @context.stubs(:capture2e)
        .with('git', 'branch', '--list', '--format=%(refname:short)')
        .returns(['', @status_mock[:false]])
      git_service = ShopifyCli::Git.new(@context)

      assert_raises ShopifyCli::Abort do
        git_service.branches
      end
    end

    def test_init_initializes_successfully
      stub_git_init(status: true, commits: true)
      git_service = ShopifyCli::Git.new(@context)

      assert_nil(git_service.init)
    end

    def test_init_raises_if_git_isnt_inited
      stub_git_init(status: false, commits: false)
      git_service = ShopifyCli::Git.new(@context)

      assert_raises ShopifyCli::Abort do
        git_service.init
      end
    end

    def test_init_raises_if_git_is_inited_but_there_are_no_commits
      stub_git_init(status: true, commits: false)
      git_service = ShopifyCli::Git.new(@context)

      assert_raises ShopifyCli::Abort do
        git_service.init
      end
    end

    def test_sha_shortcut
      fake_sha = ('c0ffee' * 6) + 'dead'
      in_repo do |_dir|
        File.write('.git/HEAD', fake_sha)

        assert_equal(fake_sha, ShopifyCli::Git.sha)
      end
    end

    def test_head_sha
      in_repo do |_dir|
        empty_commit
        refute_nil(ShopifyCli::Git.sha)
      end
    end

    def test_clones_git_repo
      ShopifyCli::Context.any_instance.expects(:system).with(
        'git',
        'clone',
        '--single-branch',
        'git@github.com:shopify/test.git',
        'test-app',
        '--progress'
      ).returns(mock(success?: true))
      capture_io do
        ShopifyCli::Git.clone('git@github.com:shopify/test.git', 'test-app')
      end
    end

    def test_clone_failure
      assert_raises(ShopifyCli::Abort) do
        ShopifyCli::Context.any_instance.expects(:system).with(
          'git',
          'clone',
          '--single-branch',
          'git@github.com:shopify/test.git',
          'test-app',
          '--progress'
        ).returns(mock(success?: false))
        capture_io do
          ShopifyCli::Git.clone('git@github.com:shopify/test.git', 'test-app')
        end
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
      ShopifyCli::Git.exec('commit', '-m', 'commit', '--allow-empty')
    end

    def stub_git_init(status:, commits:)
      output = if commits == true
        <<~EOS
          On branch master
          Your branch is up to date with 'origin/master'.

          nothing to commit, working tree clean
        EOS
      else
        <<~EOS
          On branch master

          No commits yet
        EOS
      end

      @context.stubs(:capture2e)
        .with('git', 'status')
        .returns([output, @status_mock[:"#{status}"]])
    end
  end
end
