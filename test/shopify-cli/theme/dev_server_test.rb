# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    class DevServerTest < Minitest::Test
      def test_stopped_without_any_signal
        mocked_server.start

        refute(mocked_server.stopped)
      end

      def test_stopped_with_sigterm
        pid = fork do
          mocked_server.start

          Process.kill("TERM", Process.pid)

          assert(mocked_server.stopped)
        end

        Process.wait(pid)
      end

      def test_stop_with_sigint
        pid = fork do
          mocked_server.start

          Process.kill("INT", Process.pid)

          assert(mocked_server.stopped)
        end

        Process.wait(pid)
      end

      def test_middleware_stack
        server = dev_server
        server.stubs(:theme).returns(stub)
        server.stubs(:syncer)
        server.stubs(:watcher)

        middleware_sequence = sequence("middleware sequence")

        DevServer::Proxy.expects(:new).in_sequence(middleware_sequence)
        DevServer::CdnFonts.expects(:new).in_sequence(middleware_sequence)
        DevServer::LocalAssets.expects(:new).in_sequence(middleware_sequence)
        DevServer::HotReload.expects(:new).in_sequence(middleware_sequence)

        server.send(:middleware_stack)
      end

      def test_dev_server_ignore_filter_sets_property_when_ignores_set
        ShopifyCLI::Theme::IgnoreFilter.any_instance
          .expects(:add_patterns)
          .with("ignores/**")
          .once

        server = dev_server(ignores: "ignores/**")
        server.send(:ignore_filter)
      end

      def test_dev_server_include_filter_sets_property_when_includes
        ShopifyCLI::Theme::IncludeFilter
          .expects(:new)
          .with(root, "includes/**")
          .once

        server = dev_server(includes: "includes/**")
        server.send(:include_filter)
      end

      def test_theme_when_theme_does_not_exist
        Theme
          .expects(:find_by_identifier)
          .with(ctx, root: root, identifier: theme.id)
          .returns(nil)

        error = assert_raises(CLI::Kit::Abort) do
          dev_server(identifier: theme.id).send(:theme)
        end
        assert_equal("{{x}} Theme \"1234\" doesn't exist", error.message)
      end

      def test_theme_with_valid_theme_id
        Theme
          .expects(:find_by_identifier)
          .with(ctx, root: root, identifier: theme.id)
          .returns(theme)

        dev_server(identifier: theme.id).send(:theme)
      end

      def test_theme_with_valid_theme_name
        Theme
          .expects(:find_by_identifier)
          .with(ctx, root: root, identifier: theme.name)
          .returns(theme)

        dev_server(identifier: theme.name).send(:theme)
      end

      def test_finds_or_creates_a_dev_theme_when_no_theme_specified
        Theme
          .expects(:find_by_identifier).never
        DevelopmentTheme
          .expects(:find_or_create!)
          .with(ctx, root: root).once

        dev_server.send(:theme)
      end

      def teardown
        TestHelpers::Singleton.reset_singleton!(DevServer.instance)
      end

      private

      def dev_server(identifier: nil, ignores: nil, includes: nil)
        host, port, poll, editor_sync, stable, mode = nil
        server = DevServer.instance
        server.setup(ctx, root, host, identifier, port, poll, editor_sync, stable, mode, includes, ignores)
        server
      end

      def mocked_server
        return @mocked_server if @mocked_server

        @mocked_server = dev_server
        @mocked_server.stubs(:theme).returns(stub)
        @mocked_server.stubs(:app).returns(stub(close: nil))
        @mocked_server.stubs(:sync_theme)
        @mocked_server.stubs(:middleware_stack)
        @mocked_server.stubs(:setup_server)
        @mocked_server.stubs(:start_server)
        @mocked_server.stubs(:teardown_server)
        @mocked_server
      end

      def ctx
        @ctx ||= ShopifyCLI::Context.new.tap do |context|
          context.stubs(:message).returns("default mock")
          context.stubs(:puts)
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
          "Dev Server Testing",
          root: root,
          id: 1234,
          name: "DevServer Test",
          shop: "test.myshopify.io",
          editor_url: "https://test.myshopify.io/editor",
          preview_url: "https://test.myshopify.io/preview",
          live?: false,
        )
      end
    end
  end
end
