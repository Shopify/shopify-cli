# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class PopulateTest < MiniTest::Test
      def setup
        super
        ShopifyCli::Tasks::EnsureEnv.stubs(:call)
        project_context("app_types", "rails")
        ShopifyCli::ProjectType.load_type(:rails)
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(Rails::Commands::Populate.help)
        run_cmd("populate")
      end
    end
  end
end
