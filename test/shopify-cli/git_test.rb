require "test_helper"
require "open3"
require "shellwords"

module ShopifyCLI
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
        .with("git", "branch", "--list", "--format=%(refname:short)")
        .returns(["", @status_mock[:true]])

      assert_equal(["master"], ShopifyCLI::Git.branches(@context))
    end

    def test_branches_returns_list_of_branches_if_multiple_exist
      @context.expects(:capture2e)
        .with("git", "branch", "--list", "--format=%(refname:short)")
        .returns(["master\nsecond_branch\n", @status_mock[:true]])

      assert_equal(["master", "second_branch"], ShopifyCLI::Git.branches(@context))
    end

    def test_branches_raises_if_finding_branches_fails
      @context.stubs(:capture2e)
        .with("git", "branch", "--list", "--format=%(refname:short)")
        .returns(["", @status_mock[:false]])

      assert_raises ShopifyCLI::Abort do
        ShopifyCLI::Git.branches(@context)
      end
    end

    def test_init_initializes_successfully
      stub_git_init(status: true, commits: true)
      assert_nil(ShopifyCLI::Git.init(@context))
    end

    def test_init_raises_if_git_isnt_inited
      stub_git_init(status: false, commits: false)
      assert_raises ShopifyCLI::Abort do
        ShopifyCLI::Git.init(@context)
      end
    end

    def test_init_raises_if_git_is_inited_but_there_are_no_commits
      stub_git_init(status: true, commits: false)
      assert_raises ShopifyCLI::Abort do
        ShopifyCLI::Git.init(@context)
      end
    end

    def test_sha_shortcut
      fake_sha = ("c0ffee" * 6) + "dead"
      in_repo do |git_dir|
        File.write(File.join(git_dir, "HEAD"), fake_sha)

        assert_equal(fake_sha, ShopifyCLI::Git.sha(dir: File.dirname(git_dir)))
      end
    end

    def test_head_sha
      in_repo do |git_dir|
        empty_commit(git_dir: git_dir)
        refute_nil(ShopifyCLI::Git.sha(dir: File.dirname(git_dir)))
      end
    end

    def test_clones_git_repo
      Open3.expects(:popen3).with(
        "git",
        "clone",
        "--single-branch",
        "git@github.com:shopify/test.git",
        "test-app",
        "--progress"
      ).returns(mock(success?: true))
      capture_io do
        ShopifyCLI::Git.clone("git@github.com:shopify/test.git", "test-app", ctx: @context)
      end
    end

    def test_clone_failure
      assert_raises(ShopifyCLI::Abort) do
        Open3.expects(:popen3).with(
          "git",
          "clone",
          "--single-branch",
          "git@github.com:shopify/test.git",
          "test-app",
          "--progress"
        ).returns(mock(success?: false))
        capture_io do
          ShopifyCLI::Git.clone("git@github.com:shopify/test.git", "test-app", ctx: @context)
        end
      end
    end

    private

    def in_repo
      Dir.mktmpdir do |dir|
        system("git init #{Shellwords.escape(dir)}> /dev/null")
        git_dir = File.join(dir, ".git")
        yield(File.join(git_dir))
      end
    end

    def empty_commit(git_dir:)
      _, err, stat = Context.new.capture3(
        "git",
        "--git-dir", git_dir,
        "commit",
        "--allow-empty", "-n",
        "-m", "'Initial commit'"
      )
      raise StandardError, err unless stat.success?
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
        .with("git", "status")
        .returns([output, @status_mock[:"#{status}"]])
    end
  end
end
