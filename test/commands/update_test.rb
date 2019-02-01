require 'test_helper'

module ShopifyCli
  module Commands
    class UpdateTest < MiniTest::Test
      include TestHelpers::Constants

      def setup
        super
        @dir = Dir.mktmpdir
        @command = ShopifyCli::Commands::Update.new
        redefine_constant(ShopifyCli, :ROOT, @dir)
        FileUtils.mkdir("#{ShopifyCli::ROOT}/.git")
      end

      def test_raises_if_git_process_running
        File.write("#{ShopifyCli::ROOT}/.git/HEAD.lock", 'test')
        io = capture_io do
          assert_raises ShopifyCli::AbortSilent do
            @command.call([], nil)
          end
        end
        assert_match("It looks like another git operation is in progress", io.join)
      end

      def test_raises_if_git_branch_process_running
        FileUtils.mkdir_p("#{ShopifyCli::ROOT}/.git/refs/heads")
        File.write("#{ShopifyCli::ROOT}/.git/refs/heads/master.lock", 'test')
        io = capture_io do
          assert_raises ShopifyCli::AbortSilent do
            @command.call([], nil)
          end
        end
        assert_match("It looks like another git operation is in progress", io.join)
      end

      class Stat
        def success?
          true
        end
      end

      def test_pulls_from_git
        CLI::Kit::System.expects(:capture2e)
          .returns([nil, Stat.new])
          .times(5)

        io = capture_io do
          @command.call([], nil)
        end
      end
    end
  end
end
