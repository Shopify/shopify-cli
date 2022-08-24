# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/extension/dev_server"

module ShopifyCLI
  module Theme
    module Extension
      class DevServerTest < Minitest::Test
        def test_middleware_stack
          server = dev_server
          server.stubs(:theme).returns(stub)
          server.stubs(:extension).returns(stub(root: nil))
          server.stubs(:watcher).returns(stub)

          middleware_sequence = sequence("middleware sequence")

          DevServer::Proxy.expects(:new).in_sequence(middleware_sequence)
          DevServer::CdnFonts.expects(:new).in_sequence(middleware_sequence)
          Extension::DevServer::LocalAssets.expects(:new).in_sequence(middleware_sequence)
          DevServer::HotReload.expects(:new).in_sequence(middleware_sequence)

          server.send(:middleware_stack)
        end

        def test_theme_when_theme_does_not_exist
          Theme
            .expects(:find_by_identifier)
            .with(ctx, identifier: theme.id)
            .returns(nil)

          error = assert_raises(CLI::Kit::Abort) do
            dev_server(identifier: theme.id).send(:theme)
          end

          assert_equal("{{x}} Theme \"1234\" doesn't exist", error.message)
        end

        def test_theme_with_valid_theme_id
          Theme
            .expects(:find_by_identifier)
            .with(ctx, identifier: theme.id)
            .returns(theme)

          dev_server(identifier: theme.id).send(:theme)
        end

        def test_theme_with_valid_theme_name
          Theme
            .expects(:find_by_identifier)
            .with(ctx, identifier: theme.name)
            .returns(theme)

          dev_server(identifier: theme.name).send(:theme)
        end

        def test_finds_or_creates_a_dev_theme_when_no_theme_specified
          Theme
            .expects(:find_by_identifier).never
          HostTheme
            .expects(:find_or_create!)
            .with(ctx).once

          dev_server.send(:theme)
        end

        def test_extension_when_it_is_created
          location = "http://location:1234"
          registration_id = "registration_id_5678"

          ShopifyCLI::PartnersAPI
            .expects(:query)
            .with(
              ctx,
              "extension_update_draft",
              api_key: "api_key_1234",
              registration_id: "registration_id_5678",
              config: "\"config\"",
              extension_context: "extension_context",
            )
            .returns({
              "data" => {
                "extensionUpdateDraft" => {
                  "extensionVersion" => {
                    "location" => location,
                    "registrationId" => registration_id,
                  },
                },
              },
            })

          extension1 = dev_server.send(:extension)
          extension2 = dev_server.send(:extension)

          assert_same(extension1, extension2)
          assert_equal(location, extension1.location)
          assert_equal(registration_id, extension1.registration_id)
        end

        def test_extension_when_it_is_not_created
          ShopifyCLI::PartnersAPI
            .expects(:query)
            .with(
              ctx,
              "extension_update_draft",
              api_key: "api_key_1234",
              registration_id: "registration_id_5678",
              config: "\"config\"",
              extension_context: "extension_context",
            )
            .returns({
              "data" => {
                "error" => "error message",
              },
            })

          extension1 = dev_server.send(:extension)
          extension2 = dev_server.send(:extension)

          assert_same(extension1, extension2)
          assert_nil(extension1.location)
          assert_nil(extension1.registration_id)
        end

        def teardown
          TestHelpers::Singleton.reset_singleton!(dev_server)
        end

        private

        def dev_server(identifier: nil)
          host,
          port, poll, editor_sync, stable, mode = nil
          server = Extension::DevServer.instance
          server.setup(ctx, root, host, identifier, port, poll, editor_sync, stable, mode)
          server.project = project
          server.specification_handler = specification_handler
          server
        end

        def project
          app = stub(api_key: "api_key_1234")
          stub(app: app, registration_id: "registration_id_5678")
        end

        def specification_handler
          stub(config: "config", extension_context: "extension_context")
        end

        def ctx
          @ctx ||= ShopifyCLI::Context.new.tap do |context|
            context
              .stubs(:message)
              .with("theme.serve.theme_not_found", 1234)
              .returns("Theme \"1234\" doesn't exist")

            context
              .stubs(:message)
              .with("core.login.spinner.initiating")
              .returns("")
          end
        end

        def root
          "."
        end

        def theme
          @theme ||= stub(
            "Host Theme Testing",
            root: root,
            id: 1234,
            name: "HostTheme Test",
            shop: "test.myshopify.io",
            editor_url: "https://test.myshopify.io/editor",
            preview_url: "https://test.myshopify.io/preview",
            live?: false,
          )
        end
      end
    end
  end
end
