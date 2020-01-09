# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Forms
    class DeployScriptTest < MiniTest::Test
      include TestHelpers::Partners

      def test_use_provided_language
        form = ask(api_key: 'fakekey', language: 'js')
        assert_equal(form.language, 'js')
      end

      def test_use_default_language
        form = ask(api_key: 'fakekey')
        assert_equal(form.language, 'ts')
      end

      def test_use_provided_app
        form = ask(api_key: 'fakekey')
        assert_equal(form.api_key, 'fakekey')
      end

      def test_pick_singular_app
        stub_partner_req(
          'get_apps',
          resp: {
            data: {
              apps: {
                nodes: [
                  {
                    title: 'app',
                    apiKey: 1234,
                    apiSecretKeys: [{
                      secret: 1233,
                    }],
                  },
                ],
              },
            },
          },
        )
        form = ask
        assert_equal(form.api_key, 1234)
      end

      def test_display_selection_for_apps
        stub_partner_req(
          'get_apps',
          resp: {
            data: {
              apps: {
                nodes: [
                  {
                    title: 'app',
                    apiKey: 1234,
                    apiSecretKeys: [{
                      secret: 1233,
                    }],
                  },
                  {
                    title: 'other_app',
                    apiKey: 1267,
                    apiSecretKeys: [{
                      secret: 1233,
                    }],
                  },
                ],
              },
            },
          },
        )
        CLI::UI::Prompt.expects(:ask)
          .with(
            'Which app do you want this script to belong to?'
          )
          .returns(1267)
        form = ask
        assert_equal(form.api_key, 1267)
      end

      def test_show_error_when_no_apps_exist
        stub_partner_req(
          'get_apps',
          resp: {
            data: {
              apps: {
                nodes: [],
              },
            },
          },
        )
        io = capture_io do
          assert_nil(ask)
        end
        assert(io.join.start_with?("\e[0;31m✗\e[0m You need to create an app first"))
      end

      private

      def ask(api_key: nil, language: "ts", extension_point: "discount", name: "myscript")
        DeployScript.ask(
          @context,
          [extension_point, name],
          api_key: api_key,
          language: language
        )
      end
    end
  end
end
