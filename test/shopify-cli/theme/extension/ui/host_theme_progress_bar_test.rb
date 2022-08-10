# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/extension/ui/host_theme_progress_bar"

module ShopifyCLI
  module Theme
    module Extension
      module UI
        class HostThemeProgressBarTest < Minitest::Test
          def setup
            super
            root = ShopifyCLI::ROOT + "/test/fixtures/theme"
            @ctx = TestHelpers::FakeContext.new(root: root)
            @syncer = stub("Syncer", lock_io!: nil, unlock_io!: nil, has_any_error?: false)
            @host_theme_progress_bar = UI::HostThemeProgressBar.new(@syncer, "test-theme")
          end

          def test_host_theme_progress_bar_sets_one_hundred_percent_on_success
            Git.expects(:public_send).with(:raw_clone, "https://github.com/Shopify/dawn.git", "test-theme")
            @syncer.expects(:public_send).with(:upload_theme!, delete: false)

            io, err = capture_io do
              @host_theme_progress_bar.progress(:upload_theme!, delete: false)
            end

            assert_equal "", err
            assert_includes io, "\e[1;47m\e[0m 100%\n\e[?25h" # assert progress bar is 100%
          end

          def test_clone_failure_bubbles_up_error_from_progress_bar
            destination = "test-theme"
            Dir.stubs(:exist?).with(destination).returns(true)
            Dir.stubs(:empty?).with(destination).returns(false)

            err_msg, progress = capture_io_and_assert_raises(CLI::Kit::Abort) do
              @host_theme_progress_bar.progress(:upload_theme!, delete: false)
            end

            assert_includes err_msg, "Project directory already exists. Please create a project with a new name"
            assert_includes progress[0], "\e[0m 0%  \n\e[?25h" # assert progress bar is 0%
          end
        end
      end
    end
  end
end
