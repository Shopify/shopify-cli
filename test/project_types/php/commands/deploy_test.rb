# frozen_string_literal: true
require "project_types/php/test_helper"

module PHP
  module Commands
    class DeployTest < MiniTest::Test
      def setup
        super
        project_context("app_types", "php")
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(PHP::Command::Deploy.help)
        run_cmd("app php deploy")
      end
    end
  end
end
