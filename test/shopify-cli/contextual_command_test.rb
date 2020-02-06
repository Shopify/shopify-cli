module ShopifyCli
  class ContextualCommandTest < MiniTest::Test
    def setup
      @command_name = 'create'
      @path = 'shopify-cli/commands/create/'
    end

    def test_available_in_contexts_when_context_is_in_available_list
      ShopifyCli::Commands::Registry.expects(:add).with do |param1, param2|
        assert_nil(param1.call)
        assert_equal(@command_name, param2)
      end

      Project.stubs(:current_context).returns(:top_level)
      ShopifyCli::ContextualCommand.available_in_contexts(@command_name, [:app, :script])
    end

    def test_available_in_contexts_when_context_is_not_in_available_list
      ShopifyCli::Commands::Registry.expects(:add).never

      Project.stubs(:current_context).returns(:top_level)
      ShopifyCli::ContextualCommand.available_in_contexts(@command_name, [:top_level])
    end

    def test_override_in_contexts_when_context_is_in_override_list
      Project.stubs(:current_context).returns(:app)
      # below is needed to test the correct path was autoloaded
      ShopifyCli::Commands::Registry.expects(:add).with do |param1, param2|
        begin
          param1.call
        rescue NameError => e
          assert_match("ShopifyCli::ContextualCommand::App", e.message)
        end
        assert_equal(@command_name, param2)
      end
      ShopifyCli::ContextualCommand.override_in_contexts(@command_name, [:app], @path)
    end

    def test_override_in_contexts_when_context_is_not_in_override_list
      Project.stubs(:current_context).returns(:top_level)
      ShopifyCli::Commands::Registry.expects(:add).never
      ShopifyCli::ContextualCommand.override_in_contexts(@command_name, [:app], @path)
    end
  end
end
