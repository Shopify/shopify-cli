require 'test_helper'

module ShopifyCli
  class ContextualCommandTest < MiniTest::Test
    def test_top_level_availability
      no_project_context
      Commands::Create.expects(:call)
      run_cmd('create')
    end

    def test_project_type_availability
      project_context('app_types/node')
      Commands::Serve.expects(:call)
      run_cmd('serve')
    end

    def test_app_type_specific_implementation
      project_context('app_types/rails')
      Commands::Serve::ServeRails.expects(:call)
      run_cmd('serve')
    end
  end
end
