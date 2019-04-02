require 'test_helper'

module ShopifyCli
  module Commands
    class CommandTest < MiniTest::Test
      include TestHelpers::Context

      def test_non_existant
        command = ShopifyCli::Commands::Help.new
        io = capture_io do
          command.call(%w(foobar), nil)
        end

        assert_match(/Available commands/, io.join)
      end

      class FakeCommand < ShopifyCli::Command
        prerequisite_task :tunnel

        def call(_args, _name)
          @ctx.puts('command!')
        end
      end

      def test_prerequisite_task
        @context.expects(:puts).with('success!')
        @context.expects(:puts).with('command!')
        command = FakeCommand.new(@context)
        command.call([], nil)
      end
    end
  end
end
