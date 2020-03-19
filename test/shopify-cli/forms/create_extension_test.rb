# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Forms
    class CreateAppTest < MiniTest::Test
      include TestHelpers::Partners

      def test_accepts_the_extension_name_as_positional_argument
        form = create_extension
        assert_equal form.name, 'test-extension'
      end

      def test_accepts_product_details_as_type
        form = create_extension
        assert_equal form.type, 'product-details'
      end

      def test_accepts_customer_details_as_type
        form = create_extension(type: 'customer-details')
        assert_equal form.type, 'customer-details'
      end

      def test_prompts_the_user_to_choose_a_type_if_an_unknown_type_was_provided_as_flag
        io = capture_io do
          create_extension(type: 'unknown-type')
        end

        assert_match('Invalid extension type.', io.join)
      end

      def test_prompts_the_user_to_choose_a_type_if_no_type_was_provided
        CLI::UI::Prompt.expects(:ask).with('What type of extension would you like to create?')

        capture_io do
          create_extension(type: nil)
        end
      end

      def test_accepts_the_api_key_to_associate_with_extension
        form = create_extension
        orgs = Helpers::Organizations.fetch_with_app(@context)
        assert_equal form.app['apiKey'], orgs.first['apps'].first['apiKey']
      end

      def test_prompts_the_user_to_choose_an_app_to_associate_with_extension_if_no_app_is_provided
        CLI::UI::Prompt.expects(:ask).with('Which app will you like to associate with the extension?')

        capture_io do
          create_extension(api_key: nil)
        end
      end

      def test_fails_with_invalid_api_key_to_associate_with_extension
        io = capture_io do
          form = create_extension(api_key: '00001')
        end

        assert_match('The api key does not match any of the existing apps', io.join)
      end

      private

      def create_extension(context = @context, name = ['test-extension'], type: 'product-details', api_key: '1234')
        stub_query_for_fetch_organizations_with_apps
        CreateExtension.ask(context, name, type: type, api_key: api_key)
      end

      def stub_query_for_fetch_organizations_with_apps
        stub_partner_req(
          'all_orgs_with_apps',
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    'id': 421,
                    'businessName': "one",
                    'stores': {
                      'nodes': [
                        { 'shopDomain': 'store.myshopify.com' },
                      ],
                    },
                    'apps': {
                      nodes: [{
                        id: 123,
                        title: 'app',
                        'apiKey': '1234',
                        'apiSecretKeys': [{
                          'secret': "1233",
                        }],
                      }],
                    },
                  },
                ],
              },
            },
          },
        )
      end
    end
  end
end
