# frozen_string_literal: true
require "project_types/node/test_helper"

module Node
  module Commands
    class DeployTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::Tasks::EnsureProjectType.expects(:call).with(@context, :node)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Node::Command::Deploy.help)
        run_deploy
      end

      def test_with_heroku_argument_calls_heroku
        Node::Command::Deploy::Heroku.expects(:start)
        run_deploy("heroku")
      end

      private

      def run_deploy(*args)
        run_cmd("app node deploy " + args.join(" "))
      end
    end
  end
end
