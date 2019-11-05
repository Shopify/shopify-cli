require 'test_helper'
require 'shellwords'

module ShopifyCli
  class UpdateTest < MiniTest::Test
    include TestHelpers::Constants

    class Stat
      def initialize(success: true)
        @success = success
      end

      def success?
        @success
      end
    end

    def setup
      $original_env = ENV.clone

      root = Dir.mktmpdir
      @context = TestHelpers::FakeContext.new(root: root)
      redefine_constant(ShopifyCli, :ROOT, root)
      FileUtils.mkdir("#{ShopifyCli::ROOT}/.git")
      redefine_constant(ShopifyCli::Update, :FETCH_HEAD, File.expand_path('.git/FETCH_HEAD', root))
      ShopifyCli::Config.set('autoupdate', 'enabled', true)
    end

    def teardown
      super
      ShopifyCli::Update.instance_variable_set(:@last_update_time, nil)
    end

    def test_check_now_aborts_when_head_lock_exists
      ShopifyCli::Util.expects(:development?).returns(false)
      FileUtils.touch(File.expand_path('.git/HEAD.lock', ShopifyCli::ROOT))
      ShopifyCli::Update.expects(:exec).never

      io = capture_io do
        assert_raises ShopifyCli::AbortSilent do
          ShopifyCli::Update.check_now(restart_command_after_update: true, ctx: @context)
        end
      end
      assert_match("It looks like another git operation is in progress", io.join)
    end

    def test_check_now_aborts_when_branch_head_lock_exists
      ShopifyCli::Util.expects(:development?).returns(false)
      lockfile = File.expand_path(".git/refs/heads/master.lock", ShopifyCli::ROOT)
      FileUtils.mkdir_p(File.dirname(lockfile))
      FileUtils.touch(lockfile)

      ShopifyCli::Update.expects(:exec).never

      io = capture_io do
        assert_raises ShopifyCli::AbortSilent do
          ShopifyCli::Update.check_now(restart_command_after_update: true, ctx: @context)
        end
      end
      assert_match("It looks like another git operation is in progress", io.join)
    end

    def test_updated_since_last_recorded_without_recording
      FileUtils.touch(ShopifyCli::Update::FETCH_HEAD, mtime: Time.now)

      assert(ShopifyCli::Update.updated_since_last_recorded?, message: "should have been updated")
    end

    def test_updated_since_last_recorded_with_same_mtime
      FileUtils.touch(ShopifyCli::Update::FETCH_HEAD, mtime: Time.now)
      ShopifyCli::Update.record_last_update_time

      refute(ShopifyCli::Update.updated_since_last_recorded?, message: "should not have been updated")
    end

    def test_updated_since_last_recorded_with_different_mtime
      FileUtils.touch(ShopifyCli::Update::FETCH_HEAD, mtime: Time.now - 10000)
      ShopifyCli::Update.record_last_update_time
      FileUtils.touch(ShopifyCli::Update::FETCH_HEAD, mtime: Time.now)

      assert(ShopifyCli::Update.updated_since_last_recorded?, message: "should have been updated")
    end

    def test_auto_update_doesnt_check_if_fetch_head_not_stale
      ShopifyCli::Util.expects(:testing?).returns(false)
      FileUtils.touch(ShopifyCli::Update::FETCH_HEAD, mtime: Time.now - 10)
      ShopifyCli::Update.expects(:check_now).never

      ShopifyCli::Update.auto_update
    end

    def test_auto_update_checks_if_fetch_head_stale
      ShopifyCli::Util.expects(:testing?).returns(false)
      FileUtils.touch(ShopifyCli::Update::FETCH_HEAD, mtime: Time.now - 3601)
      ShopifyCli::Update.expects(:check_now).once

      ShopifyCli::Update.auto_update
    end

    def test_auto_update_does_not_check_if_config_disabled
      ShopifyCli::Util.expects(:testing?).returns(false)
      ShopifyCli::Config.expects(:get_bool).with('autoupdate', 'enabled').returns(false)
      FileUtils.touch(ShopifyCli::Update::FETCH_HEAD, mtime: Time.now - 3601)
      ShopifyCli::Update.expects(:check_now).never

      ShopifyCli::Update.auto_update
    end

    def test_prompt_for_updates_sets_config
      ShopifyCli::Config.expects(:get_section).with('autoupdate').returns({})
      CLI::UI::Prompt.expects(:confirm).returns(true)
      ShopifyCli::Update.expects(:auto_update)

      ShopifyCli::Update.prompt_for_updates
    end

    def test_check_now_completes_but_does_not_restart
      fake_context_for_success
      ShopifyCli::Update.expects(:exec).never

      capture_io do
        ShopifyCli::Update.check_now(restart_command_after_update: false, ctx: @context)
      end
    end

    def test_check_now_completes_and_restarts
      fake_context_for_success
      ShopifyCli::Update.expects(:exec).with($PROGRAM_NAME, *ARGV, is_a(Hash))

      capture_io do
        ShopifyCli::Update.check_now(restart_command_after_update: true, ctx: @context)
      end
    end

    def test_check_now_aborts_when_master_fetch_fails
      fake_context_for_failed_fetch
      ShopifyCli::Update.expects(:exec).never

      assert_raises ShopifyCli::Abort do
        ShopifyCli::Update.check_now(restart_command_after_update: true, ctx: @context)
      end
    end

    def test_check_now_aborts_when_reset_fails
      fake_context_for_failed_reset
      ShopifyCli::Update.expects(:exec).never

      capture_io do
        assert_raises ShopifyCli::Abort do
          ShopifyCli::Update.check_now(restart_command_after_update: true, ctx: @context)
        end
      end
    end

    private

    def fake_context_for_success
      ShopifyCli::Util.expects(:development?).returns(false)
      fake_git(["fetch", "origin", 'master'])
      fake_git(["reset", "."])
      fake_git(["checkout", "."])
      fake_git(["checkout", "-f", "-B", 'master'])
      fake_git(["reset", "--hard", "FETCH_HEAD"])
    end

    def fake_context_for_failed_fetch
      ShopifyCli::Util.expects(:development?).returns(false)
      fake_git(["fetch", "origin", 'master'], success: false)
    end

    def fake_context_for_failed_reset
      ShopifyCli::Util.expects(:development?).returns(false)
      fake_git(["fetch", "origin", 'master'])
      fake_git(["reset", "."])
      fake_git(["checkout", "."])
      fake_git(["checkout", "-f", "-B", 'master'], success: false)
    end

    def fake_git(args, success: true)
      command_string = ["git", "-C", ShopifyCli::ROOT, *args]
      @context.expects(:capture2e).with(*command_string)
        .returns([nil, Stat.new(success: success)])
    end
  end
end
