# frozen_string_literal: true
require 'project_types/appconfig/test_helper'

module AppConfig
  module Commands
    class CreateTest < MiniTest::Test
      def test_prints_help_with_no_name_argument
        io = capture_io { run_cmd('create appconfig --help') }
        assert_match(CLI::UI.fmt(AppConfig::Commands::Create.help), io.join)
      end
    end
  end
end
