# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class DeployTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::Tasks::EnsureProjectType.expects(:call).with(@context, :rails)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Rails::Command::Deploy.help)
        run_deploy
      end

      def test_with_heroku_argument_calls_heroku
        Rails::Command::Deploy::Heroku.expects(:start)
        run_deploy("heroku")
      end

      private

      def run_deploy(*args)
        run_cmd("rails deploy " + args.join(" "))
      end
    end
  end
end
