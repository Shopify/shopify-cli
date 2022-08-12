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

        def teardown
          TestHelpers::Singleton.reset_singleton!(dev_server)
        end

        private

        def dev_server(identifier: nil)
          host, port, poll, editor_sync, stable, mode = nil
          server = Extension::DevServer.instance
          server.setup(ctx, root, host, identifier, port, poll, editor_sync, stable, mode)
          server
        end

        def ctx
          @ctx ||= ShopifyCLI::Context.new.tap do |context|
            context.stubs(:message)
              .with("theme.serve.theme_not_found", 1234)
              .returns("Theme \"1234\" doesn't exist")
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
