# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class DeployTest < MiniTest::Test
      def test_without_arguments_calls_help
        @context.expects(:puts).with(Rails::Command::Deploy.help)
        Rails::Command::Deploy.new(@context).call
      end
    end
  end
end
