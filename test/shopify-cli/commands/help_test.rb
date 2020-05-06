require 'test_helper'

module Rails
  module Commands
    class Fake < ShopifyCli::Command
      class << self
        def help
          "basic rails help"
        end

        def extended_help
          "extended rails help"
        end
      end
    end
  end
end

module ShopifyCli
  module Commands
    class FakeCommand < ShopifyCli::Command
      class << self
        def help
          "basic help"
        end

        def extended_help
          "extended help"
        end
      end
    end

    class HelpTest < MiniTest::Test
      def setup
        ShopifyCli::Commands.register(:FakeCommand, 'fake')
      end

      def test_default_behavior_lists_tasks
        io = capture_io do
          run_cmd('help')
        end
        output = io.join

        assert_match('Available core commands:', output)
        assert_match(/Usage: .*shopify/, output)
      end

      def test_local_commands_available_within_a_project
        Project.stubs(:current_project_type).returns('rails')
        Registry.add(->() { Rails::Commands::Fake }, 'fake_rails')

        io = capture_io do
          run_cmd('help')
        end
        output = io.join

        assert_match(/Available commands for Ruby on Rails App projects.*fake_rails/m, output)
      end

      def test_local_commands_not_available_outside_a_project
        Project.stubs(:current_project_type).returns(nil)
        Registry.add(->() { Rails::Commands::Fake }, 'fake_rails')

        io = capture_io do
          run_cmd('help')
        end
        output = io.join

        refute_match(/Available commands for Ruby on Rails App projects.*fake_rails/m, output)
      end

      def test_shows_current_project_path_and_type
        Dir.stubs(:pwd).returns("/Users/john/my_app")
        Project.stubs(:current_project_type).returns('rails')
        ShopifyCli::Commands.register("Rails::Commands::Fake", 'fake_rails')

        io = capture_io do
          run_cmd('help')
        end
        output = io.join

        assert_match("Project: my_app (Ruby on Rails App)", output)
      end

      def test_extended_help_for_individual_command
        io = capture_io do
          run_cmd('help fake')
        end
        output = io.join
        assert_match(/basic help.*extended help/m, output)
      end
    end
  end
end
