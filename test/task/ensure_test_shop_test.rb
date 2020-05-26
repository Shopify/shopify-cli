require 'test_helper'

module ShopifyCli
  module Tasks
    class EnsureTestShopTest < MiniTest::Test
      include TestHelpers::Partners

      def setup
        super
        @context = TestHelpers::FakeContext.new
      end

      def test_outputs_if_shop_cant_be_queried
        stub_org_request
        stub_env(domain: 'notther.myshopify.com')
        @context.expects(:puts).with("Couldn't verify your shop notther.myshopify.com")
        EnsureTestShop.call(@context)
      end

      def test_noop_if_already_transfer_disabled
        stub_org_request(transfer_disabled: true)
        stub_env
        CLI::UI::Prompt.expects(:confirm).never
        EnsureTestShop.call(@context)
      end

      def test_will_prompt_to_convert
        stub_org_request
        stub_env
        CLI::UI::Prompt.expects(:confirm).returns(false)
        EnsureTestShop.call(@context)
      end

      def test_can_convert
        stub_org_request
        stub_env
        CLI::UI::Prompt.expects(:confirm).returns(true)
        stub_partner_req(
          'convert_dev_to_test_store',
          variables: {
            input: {
              organizationID: 42,
              shopId: 142,
            },
          }
        )
        @context.expects(:puts).with("{{v}} Transfer has been disabled on shopdomain.myshopify.com.")
        EnsureTestShop.call(@context)
      end

      private

      def stub_env(domain: 'shopdomain.myshopify.com')
        Project.current.stubs(:env).returns(
          Resources::EnvFile.new(
            api_key: '123',
            secret: 'kjhasas',
            shop: domain,
          )
        )
      end

      def stub_org_request(domain: 'shopdomain.myshopify.com', transfer_disabled: false)
        stub_partner_req(
          'all_organizations',
          'resp': {
            'data': {
              'organizations': {
                'nodes': [
                  {
                    'id': 42,
                    'stores': {
                      'nodes': [{
                        'shopId': 142,
                        'shopDomain': domain,
                        'transferDisabled': transfer_disabled,
                      }],
                    },
                  },
                ],
              },
            },
          }
        )
      end
    end
  end
end
