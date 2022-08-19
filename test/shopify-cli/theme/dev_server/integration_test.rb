# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    class DevServer
      class IntegrationTest < Minitest::Test
        include TestHelpers::FakeUI

        THEMES_API_URL = "https://dev-theme-server-store.myshopify.com/admin/api/unstable/themes/123456789.json"
        ASSETS_API_URL = "https://dev-theme-server-store.myshopify.com/admin/api/unstable/themes/123456789/assets.json"

        def setup
          super

          ShopifyCLI::DB.expects(:exists?).with(:shop).at_least_once.returns(true)
          ShopifyCLI::DB.expects(:get).with(:shop).at_least_once.returns("dev-theme-server-store.myshopify.com")

          ShopifyCLI::DB.stubs(:get).with(:shopify_exchange_token).returns("token123")
          ShopifyCLI::DB.stubs(:get).with(:development_theme_name).returns("Development theme")
          ShopifyCLI::DB.stubs(:get).with(:development_theme_id).returns("123456789")
          ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(nil)

          # Avoid conflicts with Thread.pass
          ShopifyCLI::Theme::Syncer.any_instance.stubs(:wait!)
        end

        def teardown
          if @server_thread
            DevServer.stop
            TestHelpers::Singleton.reset_singleton!(DevServer.instance)
            @server_thread.join
          end
        end

        def test_proxy_to_sfr
          puts __method__
          # skip("Causing flaky behavior in CI, need to revisit")
          port = 9292
          WebMock.disable_net_connect!(allow: "127.0.0.1:#{port}")

          stub_request(:any, ASSETS_API_URL)
            .to_return(status: 200, body: "{}")
          stub_request(:any, THEMES_API_URL)
            .to_return(status: 200, body: "{}")
          stub_request(:head, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0&preview_theme_id=123456789")
            .to_return(
              status: 200,
              headers: {
                "Set-Cookie" => "_secure_session_id=abcd1234",
              }
            )
          stub_sfr = stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")

          start_server(port)
          response = get(port,"/")

          refute_server_errors(response)
          assert_requested(stub_sfr)
        end

        def test_uploads_files_on_boot
          puts __method__
          # skip("Causing flaky behavior in CI, need to revisit")
          port = 9293
          WebMock.disable_net_connect!(allow: "127.0.0.1:#{port}")
          start_server_and_wait_sync_files(port)

          # Should upload all theme files except the ignored files
          ignored_files = %w[config.yml super_secret.json settings_data.json ignores_file]
          theme_root = "#{ShopifyCLI::ROOT}/test/fixtures/theme"

          Pathname.new(theme_root).glob("**/*").each do |file|
            next unless file.file? && !ignored_files.include?(file.basename.to_s)
            asset = { key: file.relative_path_from(theme_root).to_s }
            if file.extname == ".png"
              asset[:attachment] = Base64.encode64(file.read)
            else
              asset[:value] = file.read
            end

            assert_requested(:put, ASSETS_API_URL,
              body: JSON.generate(asset: asset),
              at_least_times: 1)
          end
        end

        def test_uploads_files_on_modification
          puts __method__
          # skip("Causing flaky behavior in CI, need to revisit")
          port = 9294
          WebMock.disable_net_connect!(allow: "127.0.0.1:#{port}")
          start_server_and_wait_sync_files(port)

          theme_root = "#{ShopifyCLI::ROOT}/test/fixtures/theme"

          # Modify a file. Should upload on the fly.
          file = Pathname.new("#{theme_root}/assets/added.css")
          begin
            file.write("added")
            with_retries(Minitest::Assertion) do
              assert_requested(:put, ASSETS_API_URL,
                body: JSON.generate(
                  asset: {
                    key: "assets/added.css",
                    value: "added",
                  }
                ),
                at_least_times: 1)
            end
          ensure
            file.delete
          end
        end

        def test_serve_assets_locally
          puts __method__
          # skip("Causing flaky behavior in CI, need to revisit")
          port = 9295
          WebMock.disable_net_connect!(allow: "127.0.0.1:#{port}")
          response = start_server_and_wait_sync_files(port)

          refute_server_errors(response)
        end

        def test_address_already_in_use
          puts __method__
          # skip("Causing flaky behavior in CI, need to revisit")
          port = 9296
          WebMock.disable_net_connect!(allow: "127.0.0.1:#{port}")
          start_server_and_wait_sync_files(port)

          # Stub StandardReporter#report to keep test logs clean
          ShopifyCLI::Theme::Syncer::StandardReporter.any_instance.stubs(:report)

          @ctx.output_captured = true
          io = capture_io_and_assert_raises(ShopifyCLI::AbortSilent) do
            DevServer.start(@ctx, "#{ShopifyCLI::ROOT}/test/fixtures/theme", port: port, stable: true)
          end
          @ctx.output_captured = false

          io_messages = io.join

          assert_match(@ctx.message("theme.serve.address_already_in_use", "http://127.0.0.1:#{port}"), io_messages)
          assert_match(@ctx.message("theme.serve.try_port_option"), io_messages)
        end

        def test_streams_hot_reload_events
          puts __method__
          # skip("Causing flaky behavior in CI, need to revisit")
          port = 9297
          WebMock.disable_net_connect!(allow: "127.0.0.1:#{port}")
          start_server_and_wait_sync_files(port)

          # Send the SSE request
          socket = TCPSocket.new("127.0.0.1", port)
          socket.write("GET /hot-reload HTTP/1.1\r\n")
          socket.write("Host: 127.0.0.1\r\n")
          socket.write("\r\n")
          socket.flush
          # Read the head
          assert_includes(socket.readpartial(1024), "HTTP/1.1 200 OK")
          # Add a file
          file = Pathname.new("#{ShopifyCLI::ROOT}/test/fixtures/theme/assets/theme.css")
          file.write("modified")
          begin
            assert_equal("2a\r\ndata: {\"modified\":[\"assets/theme.css\"]}\n\n\n\r\n", socket.readpartial(1024))
          ensure
            file.write("")
          end
          socket.close
        end

        def test_forbidden_error
          puts __method__
          # skip("Causing flaky behavior in CI, need to revisit")
          port = 9298
          WebMock.disable_net_connect!(allow: "127.0.0.1:#{port}")

          root = "#{ShopifyCLI::ROOT}/test/fixtures/theme"
          ctx = TestHelpers::FakeContext.new(root: root)
          error_message = "error message"
          shop = "dev-theme-server-store.myshopify.com"

          ctx.stubs(:message).returns("")
          ctx.stubs(:message).with("theme.serve.ensure_user", shop).returns(error_message)

          ctx.expects(:abort).with(error_message)

          DevelopmentTheme.stubs(:find_or_create!).raises(ShopifyCLI::API::APIRequestForbiddenError)
          DevServer.start(ctx, "#{ShopifyCLI::ROOT}/test/fixtures/theme", port: port, stable: true)
        end

        private

        def start_server(port)
          @ctx = TestHelpers::FakeContext.new(root: "#{ShopifyCLI::ROOT}/test/fixtures/theme")

          @server_thread = Thread.new do
            DevServer.start(@ctx, "#{ShopifyCLI::ROOT}/test/fixtures/theme", port: port, stable: true)
          rescue => e
            puts "Failed to start DevServer:"
            puts e.message
            puts e.backtrace
          end
        end

        def start_server_and_wait_sync_files(port)
          # Get the checksums
          stub_request(:any, ASSETS_API_URL)
            .to_return(status: 200, body: "{}")
          stub_request(:any, THEMES_API_URL)
            .to_return(status: 200, body: "{}")
          # Stub request to get deleted file after file.delete is called
          stub_request(:get, "#{ASSETS_API_URL}?asset%5Bkey%5D=assets/added.css")
            .to_return(status: 200, body: "{}")

          start_server(port)
          # Wait for server to start & sync the files
          get(port, "/assets/bogus.css")
        end

        def refute_server_errors(response)
          refute_match(/error/i, response, response)
        end

        def get(port, path)
          with_retries(Errno::ECONNREFUSED) do
            Net::HTTP.get(URI("http://127.0.0.1:#{port}#{path}"))
          end
        end

        def with_retries(*exceptions, retries: 10)
          yield
        rescue *exceptions
          retries -= 1
          if retries > 0
            sleep(0.5)
            retry
          else
            raise
          end
        end
      end
    end
  end
end
