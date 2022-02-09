# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    module DevServer
      class IntegrationTest < Minitest::Test
        include TestHelpers::FakeUI

        @@port = 9292 # rubocop:disable Style/ClassVars

        THEMES_API_URL = "https://dev-theme-server-store.myshopify.com/admin/api/unstable/themes/123456789.json"
        ASSETS_API_URL = "https://dev-theme-server-store.myshopify.com/admin/api/unstable/themes/123456789/assets.json"

        def setup
          super
          WebMock.disable_net_connect!(allow: "127.0.0.1:#{@@port}")

          ShopifyCLI::DB.expects(:get)
            .with(:shopify_exchange_token)
            .at_least_once.returns("token123")

          ShopifyCLI::DB.expects(:exists?).with(:shop).at_least_once.returns(true)
          ShopifyCLI::DB.expects(:get)
            .with(:shop)
            .at_least_once.returns("dev-theme-server-store.myshopify.com")
          ShopifyCLI::DB.stubs(:get)
            .with(:development_theme_name)
            .returns("Development theme")
          ShopifyCLI::DB.stubs(:get)
            .with(:development_theme_id)
            .returns("123456789")
          ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(nil)
        end

        def teardown
          if @server_thread
            DevServer.stop
            @server_thread.join
          end
          @@port += 1 # rubocop:disable Style/ClassVars
        end

        def test_proxy_to_sfr
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

          start_server
          response = get("/")

          refute_server_errors(response)
          assert_requested(stub_sfr)
        end

        def test_uploads_files_on_boot
          start_server_and_wait_sync_files

          # Should upload all theme files except the ignored files
          ignored_files = [
            "config.yml",
            "super_secret.json",
            "settings_data.json",
            "ignores_file",
          ]
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
          start_server_and_wait_sync_files

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
          response = start_server_and_wait_sync_files

          refute_server_errors(response)
        end

        def test_address_already_in_use
          start_server_and_wait_sync_files

          # Stub StandardReporter#report to keep test logs clean
          ShopifyCLI::Theme::Syncer::StandardReporter.any_instance.stubs(:report)

          @ctx.output_captured = true
          io = capture_io_and_assert_raises(ShopifyCLI::AbortSilent) do
            DevServer.start(@ctx, "#{ShopifyCLI::ROOT}/test/fixtures/theme", port: @@port)
          end
          @ctx.output_captured = false

          io_messages = io.join

          assert_match(@ctx.message("theme.serve.address_already_in_use", "http://127.0.0.1:#{@@port}"), io_messages)
          assert_match(@ctx.message("theme.serve.try_port_option"), io_messages)
        end

        def test_streams_hot_reload_events
          start_server_and_wait_sync_files

          # Send the SSE request
          socket = TCPSocket.new("127.0.0.1", @@port)
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

        private

        def start_server
          @ctx = TestHelpers::FakeContext.new(root: "#{ShopifyCLI::ROOT}/test/fixtures/theme")
          @server_thread = Thread.new do
            DevServer.start(@ctx, "#{ShopifyCLI::ROOT}/test/fixtures/theme", port: @@port)
          rescue Exception => e
            puts "Failed to start DevServer:"
            puts e.message
            puts e.backtrace
          end
        end

        def start_server_and_wait_sync_files
          # Get the checksums
          stub_request(:any, ASSETS_API_URL)
            .to_return(status: 200, body: "{}")
          stub_request(:any, THEMES_API_URL)
            .to_return(status: 200, body: "{}")

          start_server
          # Wait for server to start & sync the files
          get("/assets/bogus.css")
        end

        def refute_server_errors(response)
          refute_match(/error/i, response, response)
        end

        def get(path)
          with_retries(Errno::ECONNREFUSED) do
            Net::HTTP.get(URI("http://127.0.0.1:#{@@port}#{path}"))
          end
        end

        def with_retries(*exceptions, retries: 5)
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
