require 'test_helper'

module CLI
  module Kit
    class BaseCommandTest < MiniTest::Test
      class ExampleCommand < BaseCommand
        def self.stat(*)
          nil
        end

        def self.statsd_increment(metric, **kwargs)
          stat(:increment, metric, **kwargs)
        end

        def self.statsd_time(metric, **kwargs)
          a = yield
          stat(:time, metric, **kwargs)
          a
        end

        def call(args, _name)
        end
      end

      def expected_tags
        %w(task:CLI::Kit::BaseCommandTest::ExampleCommand command:command)
      end

      def test_self_call_sends_statsd_on_success
        ExampleCommand.expects(:stat).with(
          :increment,
          "cli.command.invoked",
          tags: expected_tags
        )
        ExampleCommand.any_instance.expects(:call).with([], "command")
        ExampleCommand.expects(:stat).with(
          :time,
          "cli.command.time",
          tags: expected_tags
        )
        ExampleCommand.expects(:stat).with(
          :increment,
          "cli.command.success",
          tags: expected_tags
        )

        ExampleCommand.call([], "command")
      end

      def test_self_call_sends_statsd_on_failure
        ExampleCommand.expects(:stat).with(
          :increment,
          "cli.command.invoked",
          tags: expected_tags
        )
        ExampleCommand.any_instance.expects(:call)
          .with([], "command")
          .raises(RuntimeError, 'something went wrong.')

        ExampleCommand.expects(:stat).with(
          :increment,
          "cli.command.exception",
          tags: expected_tags + ["exception:RuntimeError"]
        )

        e = assert_raises RuntimeError do
          ExampleCommand.call([], "command")
        end
        assert_equal 'something went wrong.', e.message
      end

      def test_self_call_adds_subcommand_tag_and_fails
        ExampleCommand.any_instance.expects(:has_subcommands?).returns(true)

        ExampleCommand.expects(:stat).with(
          :increment,
          "cli.command.invoked",
          tags: expected_tags + ["subcommand:test"]
        )
        ExampleCommand.any_instance.expects(:call)
          .with(['test'], "command")
          .raises(RuntimeError, 'something went wrong.')

        ExampleCommand.expects(:stat).with(
          :increment,
          "cli.command.exception",
          tags: expected_tags + ["subcommand:test", "exception:RuntimeError"]
        )

        e = assert_raises RuntimeError do
          ExampleCommand.call(['test'], "command")
        end
        assert_equal 'something went wrong.', e.message
      end

      def test_self_call_records_time
        ExampleCommand.expects(:stat).with(
          :increment,
          "cli.command.invoked",
          tags: expected_tags
        )
        ExampleCommand.expects(:stat).with(
          :time,
          "cli.command.time",
          tags: expected_tags
        )
        ExampleCommand.expects(:stat).with(
          :increment,
          "cli.command.success",
          tags: expected_tags
        )

        ExampleCommand.call([], "command")
      end
    end
  end
end
