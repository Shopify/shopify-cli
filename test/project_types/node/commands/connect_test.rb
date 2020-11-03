# frozen_string_literal: true
require 'project_types/node/test_helper'

module Node
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners

      ORG = { 'id' => '620',
              'businessName' => 'idk',
              'stores' => [{
                'shopId' => '420',
                'shopDomain' => 'shop.myshopify.com',
                'shopName' => 'My Shop',
              }],
              'apps' => [{
                'id' => '80',
                'title' => 'node-app',
                'apiKey' => 'bomk',
                'apiSecretKeys' => [{ 'secret' => 'boop' }],
              }] }

      def test_can_connect
        context = ShopifyCli::Context.new

        ShopifyCli::Project.expects(:has_current?).returns(false)
        ShopifyCli::Commands::Connect.expects(:default_connect)
          .with('node')
          .returns([ORG, 'bomk'])
        context.expects(:done)
          .with(context.message('core.connect.connected', 'node-app'))

        Node::Commands::Connect.new(context).call
      end

      def test_warns_if_in_production
        context = ShopifyCli::Context.new

        ShopifyCli::Project.stubs(:current_project_type).returns(:node)
        context.expects(:puts)
          .with(context.message('core.connect.production_warning'))
        ShopifyCli::Commands::Connect.expects(:default_connect)
          .with('node')
          .returns([ORG, 'bomk'])
        context.expects(:done)
          .with(context.message('core.connect.connected', 'node-app'))

        Node::Commands::Connect.new(context).call
      end
    end
  end
end
