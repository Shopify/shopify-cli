require 'test_helper'

module ShopifyCli
  module Commands
    class ConnectTest < MiniTest::Test
      include TestHelpers::Partners

      def test_runs_project_type_connect_if_exists
        ShopifyCli::Project.stubs(:has_current?).returns(false)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).returns('node')
        ShopifyCli::ProjectType.load_type('node')
        ::Node::Commands::Connect.expects(:call)
          .with([], 'connect', 'connect')

        ShopifyCli::Commands::Connect.new(@context).call([], 'connect')
      end

      def test_prompts_project_type_if_invalid_arg
        ShopifyCli::Project.stubs(:has_current?).returns(false)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).returns('node')
        ShopifyCli::ProjectType.load_type('node')
        ::Node::Commands::Connect.expects(:call)
          .with(['edge'], 'connect', 'connect')

        ShopifyCli::Commands::Connect.new(@context).call(['edge'], 'connect')
      end

      def test_runs_default_behaviour_if_no_connect_command
        ShopifyCli::Project.stubs(:has_current?).returns(false)
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).returns('edge')
        ShopifyCli::Tasks::EnsureEnv.expects(:call).with(@context, regenerate: true).returns(org_response)
        ShopifyCli::Project.expects(:write)
        ShopifyCli::Commands::Connect.new(@context).call([], 'connect')
      end

      def test_not_write_yml_when_current_project_exists_in_default
        CLI::UI::Prompt.expects(:ask).with(@context.message('core.connect.project_type_select')).returns('edge')
        ShopifyCli::Tasks::EnsureEnv.expects(:call).with(@context, regenerate: true).returns(org_response)
        ShopifyCli::Project.expects(:write).never
        ShopifyCli::Commands::Connect.new(@context).call([], 'connect')
      end

      def test_outputs_warnings_if_already_connected_in_default
        context = ShopifyCli::Context.new

        context.expects(:puts).with(context.message('core.connect.already_connected_warning'))
        CLI::UI::Prompt.expects(:ask).with(context.message('core.connect.project_type_select')).returns('edge')
        ShopifyCli::Tasks::EnsureEnv.expects(:call).with(context, regenerate: true).returns(org_response)
        ShopifyCli::Project.expects(:write).never

        context.expects(:done).with(context.message('core.connect.connected', 'app'))

        ShopifyCli::Commands::Connect.new(context).call([], 'connect')
      end

      private

      def org_response
        {
          "id" => 101,
          "businessName" => "two",
          "stores" => [
            { "shopDomain" => "store2.myshopify.com", "shopName" => "foo" },
            { "shopDomain" => "store1.myshopify.com", "shopName" => "bar" },
          ],
          "apps" => [{
            "title" => "app",
            "apiKey" => "apikey",
            "apiSecretKeys" => [{
              "secret" => 1234,
            }],
          }],
        }
      end
    end
  end
end
