# frozen_string_literal: true
require "project_types/node/test_helper"

module Node
  module Commands
    class GenerateTest < MiniTest::Test
      def test_without_arguments_calls_help
        @context.expects(:puts).with(Node::Command::Generate.help)
        Node::Command::Generate.new(@context).call
      end
    end
  end
end
