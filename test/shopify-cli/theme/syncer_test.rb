# frozen_string_literal: true
require "test_helper"
require "timecop"
require "shopify_cli/theme/syncer"
require "shopify_cli/theme/theme"

module ShopifyCLI
  module Theme
    class SyncerTest < Minitest::Test
      def setup
        super
        root = ShopifyCLI::ROOT + "/test/fixtures/theme"
        Environment.stubs(:admin_auth_token).returns("env_token")
        ShopifyCLI::DB
          .stubs(:get)
          .with(:development_theme_id)
          .returns("12345678")

        ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
        ShopifyCLI::DB
          .stubs(:get)
          .with(:shop)
          .returns("dev-theme-server-store.myshopify.com")
        @ctx = TestHelpers::FakeContext.new(root: root)
        @theme = Theme.new(@ctx, root: root)
        @syncer = Syncer.new(@ctx, theme: @theme)
        File.any_instance.stubs(:write)
      end

      def teardown
        super
        @syncer.shutdown
      end

      def test_update_text_file
        @syncer.start_threads
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          method: "PUT",
          api_version: "unstable",
          body: JSON.generate({
            asset: {
              key: "assets/theme.css",
              value: @theme["assets/theme.css"].read,
            },
          })
        ).returns([
          200,
          {
            "asset" => {
              "key" => "assets/theme.css",
              "checksum" => @theme["assets/theme.css"].checksum,
            },
          },
          {},
        ])

        @syncer.enqueue_updates([@theme["assets/theme.css"]])
        @syncer.wait!
      end

      def test_update_text_file_bulk
        @syncer.start_threads
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets/bulk.json",
          api_version: "unstable",
          method: "PUT",
          body: JSON.generate({
            asset: {
              key: "assets/theme.css",
              value: @theme["assets/theme.css"].read,
            },
          })
        ).returns(
          [
            [
              200,
              {
                "asset" => {
                  "key" => "assets/theme.css",
                  "checksum" => @theme["assets/theme.css"].checksum,
                },
              },
            ],
          ],
        )

        @syncer.enqueue_updates([@theme["assets/theme.css"]])
        @syncer.wait!
      end

      def test_update_binary_file
        @syncer.start_threads
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          method: "PUT",
          api_version: "unstable",
          body: JSON.generate({
            asset: {
              key: "assets/logo.png",
              attachment: Base64.encode64(@theme["assets/logo.png"].read),
            },
          })
        ).returns([
          200,
          {
            "asset" => {
              "key" => "assets/logo.png",
              "checksum" => @theme["assets/logo.png"].checksum,
            },
          },
          {},
        ])

        @syncer.enqueue_updates([@theme["assets/logo.png"]])
        @syncer.wait!
      end

      def test_delete_file
        @syncer.start_threads
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          method: "DELETE",
          api_version: "unstable",
          body: JSON.generate({
            asset: {
              key: "assets/theme.css",
            },
          })
        ).returns([
          200,
          {
            "message": "assets/theme.css was successfully deleted",
          },
          {},
        ])

        @syncer.enqueue_deletes([@theme["assets/theme.css"]])
        @syncer.wait!
      end

      def test_union_merge_file
        file = @theme["assets/theme.css"]

        ShopifyCLI::AdminAPI
          .expects(:rest_request)
          .with(
            @ctx,
            api_version: "unstable",
            method: "GET",
            shop: @theme.shop,
            path: "themes/#{@theme.id}/assets.json",
            query: "asset%5Bkey%5D=assets%2Ftheme.css"
          )
          .returns([200, { "asset" => { "value" => "new content" } }, {}])

        Syncer::Merger
          .expects(:union_merge)
          .with(file, "new content")
          .returns("merged content")

        file.expects(:write).with("merged content")

        @syncer.expects(:enqueue).with(:update, file)
        @syncer.send(:union_merge, file) {}
      end

      def test_enqueue_union_merges
        file = @theme["assets/theme.css"]

        @syncer.expects(:enqueue).with(:union_merge, file)
        @syncer.start_threads
        @syncer.enqueue_union_merges([file])
        @syncer.wait!
      end

      def test_union_merge_file_when_file_is_not_a_text
        file = @theme["assets/logo.png"]

        ShopifyCLI::AdminAPI
          .expects(:rest_request)
          .with(
            @ctx,
            api_version: "unstable",
            method: "GET",
            shop: @theme.shop,
            path: "themes/#{@theme.id}/assets.json",
            query: "asset%5Bkey%5D=assets%2Flogo.png"
          )
          .returns([200, {}, {}])

        Syncer::Merger.expects(:union_merge).never

        file.expects(:write).never

        @syncer.start_threads
        @syncer.enqueue_union_merges([file])
        @syncer.wait!
      end

      def test_upload_when_unmodified
        @syncer.start_threads
        @syncer.checksums["assets/theme.css"] = @theme["assets/theme.css"].checksum

        ShopifyCLI::AdminAPI.expects(:rest_request).never

        @syncer.enqueue_updates([@theme["assets/theme.css"]])
        @syncer.wait!
      end

      def test_fetch_checksums
        @syncer.start_threads
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          api_version: "unstable",
          method: "GET",
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",

        ).returns([
          200,
          {
            "assets" => [{
              "key" => "assets/theme.css",
              "checksum" => @theme["assets/theme.css"].checksum,
            }],
          },
          {},
        ])

        @syncer.fetch_checksums!

        assert_equal(@theme["assets/theme.css"].checksum, @syncer.checksums["assets/theme.css"])
      end

      def test_fetch_checksums_with_duplicate_liquid_assets
        @syncer.start_threads
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: @theme.shop,
          api_version: "unstable",
          method: "GET",
          path: "themes/#{@theme.id}/assets.json",

        ).returns([
          200,
          {
            "assets" => [
              {
                "key" => "assets/generated.css",
                "checksum" => @theme["assets/generated.css.liquid"].checksum,
              },
              {
                "key" => "assets/generated.css.liquid",
                "checksum" => @theme["assets/generated.css.liquid"].checksum,
              },
            ],
          },
          {},
        ])

        @syncer.fetch_checksums!

        assert(@syncer.checksums["assets/generated.css.liquid"])
        refute(@syncer.checksums["assets/generated.css"])
      end

      def test_update_checksum_after_upload
        @syncer.start_threads
        ShopifyCLI::AdminAPI.expects(:rest_request).returns([
          200,
          {
            "asset" => {
              "key" => "assets/theme.css",
              "checksum" => "deadbeef",
            },
          },
          {},
        ])

        @syncer.enqueue_updates([@theme["assets/theme.css"]])
        @syncer.wait!

        assert_equal("deadbeef", @syncer.checksums["assets/theme.css"])
      end

      def test_theme_files_are_pending_during_upload
        file = @theme.static_asset_files.first

        @ctx.expects(:error).once
        @syncer.enqueue_updates([file])
        assert_includes(@syncer.pending_updates, file)

        @syncer.start_threads
        @syncer.wait!
        assert_empty(@syncer.pending_updates)
      end

      def test_logs_upload_error
        file = @theme.static_asset_files.first
        @ctx.expects(:error)

        response_body = JSON.generate(errors: { message: "oops" })
        ShopifyCLI::AdminAPI.stubs(:rest_request).raises(client_error(response_body))

        @syncer.enqueue_updates([file])

        @syncer.start_threads
        @syncer.wait!
      end

      def test_upload_theme
        @syncer.start_threads

        expected_size = @theme.theme_files.size

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .times(expected_size + 1) # +1 for checksums
          .returns([200, {}, {}])

        @syncer.upload_theme!
        assert_empty(@syncer)
      end

      def test_download_theme
        @syncer.start_threads
        @theme.theme_files
          .reject { |file| file.relative_path == "assets/generated.css.liquid" }
          .each { |file| @syncer.checksums[file.relative_path] = "OUTDATED" }

        expected_size = @theme.theme_files.size - 1 # 1 deleted file

        File.any_instance.expects(:delete).times(1)
        File.any_instance.expects(:write)
          .times(expected_size)
          .with("new content")

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .at_least(expected_size + 1) # +1 for checksums
          .returns([
            200,
            {
              "asset" => {
                "value" => "new content",
              },
            },
            {},
          ])

        @syncer.download_theme!
        assert_empty(@syncer)
      end

      def test_download_theme_with_include_filter
        @syncer.include_filter = mock("IncludeFilter")
        @syncer.include_filter.stubs(:match?).returns(false)
        @syncer.include_filter.expects(:match?).with("layout/theme.liquid").returns(true)

        @syncer.start_threads

        @theme.theme_files.each { |file| @syncer.checksums[file.relative_path] = "OUTDATED" }

        File.any_instance.expects(:write)
          .with("new content")
          .once

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .times(2) # +1 for checksums
          .returns([
            200,
            {
              "asset" => {
                "value" => "new content",
              },
            },
            {},
          ])

        @syncer.download_theme!
        assert_empty(@syncer)
      end

      def test_download_theme_with_ignores
        @syncer.ignore_filter = mock("IgnoreFilter")
        @syncer.ignore_filter.stubs(:ignore?).returns(false)
        @syncer.ignore_filter.expects(:ignore?).with(@theme["assets/generated.css.liquid"].path).returns(true)

        @syncer.start_threads

        @theme.theme_files
          .reject { |file| file.relative_path == "assets/generated.css.liquid" }
          .each { |file| @syncer.checksums[file.relative_path] = file.checksum }

        File.any_instance.expects(:delete).never
        File.any_instance.expects(:write).never

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .at_least(1) # 1 for checksums
          .returns([200, {}, {}])

        @syncer.download_theme!
        assert_empty(@syncer)
      end

      def test_download_theme_without_checksum
        @syncer.start_threads
        @theme.theme_files.each { |file| @syncer.checksums[file.relative_path] = nil }

        expected_size = @theme.theme_files.size

        File.any_instance.expects(:write)
          .times(expected_size)
          .with("new content")

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .at_least(expected_size + 1) # +1 for checksums
          .returns([
            200,
            {
              "asset" => {
                "value" => "new content",
              },
            },
            {},
          ])

        @syncer.download_theme!
        assert_empty(@syncer)
      end

      def test_upload_theme_with_delayed_low_priority_files
        @syncer.start_threads

        expected_size = (@theme.liquid_files + @theme.json_files).size

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .at_least(expected_size)
          .returns([200, {}, {}])

        @syncer.upload_theme!(delay_low_priority_files: true)

        @syncer.wait!
        assert_empty(@syncer)
      end

      def test_upload_theme_deletes_missing_files
        @syncer.start_threads

        expected_files = @theme.theme_files

        response_assets = expected_files.map do |file|
          {
            "key" => file.relative_path,
            "checksum" => file.checksum,
          }
        end

        # Add a file that was removed locally
        response_assets << {
          "key" => "assets/removed.css",
          "checksum" => "deadbeef",
        }

        # Checksum request
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          api_version: "unstable",
          method: "GET",
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json"
        ).returns([
          200,
          { "assets" => response_assets },
          {},
        ])

        # Other assets have matching checksum, so should not be uploaded
        ShopifyCLI::AdminAPI.expects(:rest_request)
          .with(@ctx, has_entries(method: "PUT"))
          .never

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .with(@ctx, has_entries(
            method: "DELETE",
            body: JSON.generate(
              asset: {
                key: "assets/removed.css",
              },
            )
          ))
          .returns([200, {}, {}])

        @syncer.upload_theme!
      end

      def test_upload_theme_deletes_missing_files_when_delete_is_true
        @syncer.stubs(:overwrite_json?).returns(false)
        @syncer.stubs(:fetch_checksums!)
        @syncer.checksums[removed_css_file.relative_path] = "removed non-JSON file"
        @syncer.checksums[removed_json_file.relative_path] = "removed JSON file"

        @syncer.expects(:enqueue_deletes).with([removed_css_file])
        @syncer.expects(:enqueue_json_deletes).with([removed_json_file])
        @syncer.expects(:enqueue_updates).with(@theme.liquid_files)
        @syncer.expects(:enqueue_updates).with(@theme.static_asset_files)
        @syncer.expects(:enqueue_json_updates).with(@theme.json_files)

        @syncer.start_threads
        @syncer.upload_theme!(delete: true)
      end

      def test_upload_theme_deletes_missing_files_when_delete_is_false
        @syncer.stubs(:overwrite_json?).returns(false)
        @syncer.stubs(:fetch_checksums!)
        @syncer.checksums[removed_css_file.relative_path] = "removed non-JSON file"
        @syncer.checksums[removed_json_file.relative_path] = "removed JSON file"

        @syncer.expects(:enqueue_deletes).never
        @syncer.expects(:enqueue_json_deletes).never
        @syncer.expects(:enqueue_updates).with(@theme.liquid_files)
        @syncer.expects(:enqueue_updates).with(@theme.static_asset_files)
        @syncer.expects(:enqueue_json_updates).with(@theme.json_files)

        @syncer.start_threads
        @syncer.upload_theme!(delete: false)
      end

      def test_backoff_near_api_limit
        @syncer.start_threads
        file = @theme.liquid_files.first

        ShopifyCLI::AdminAPI.expects(:rest_request).returns([
          200,
          {},
          {
            "x-shopify-shop-api-call-limit" => "39/40",
          },
        ])

        @syncer.expects(:sleep).with(2)

        @syncer.enqueue_updates([file])
        @syncer.wait!
      end

      def test_dont_backoff_under_api_limit
        @syncer.start_threads
        file = @theme.liquid_files.first

        ShopifyCLI::AdminAPI.expects(:rest_request).returns([
          200,
          {},
          {
            "x-shopify-shop-api-call-limit" => "5/40",
          },
        ])

        @syncer.expects(:sleep).never

        @syncer.enqueue_updates([file])
        @syncer.wait!
      end

      def test_log_api_errors
        mock_context_error_message
        @ctx.expects(:error).with(<<~EOS.chomp)
          12:30:59 {{red:ERROR }} {{>}} {{blue:update sections/footer.liquid}}:
            An error
            Then some
          EOS

        @syncer.start_threads
        file = @theme["sections/footer.liquid"]

        response_body = JSON.generate(
          errors: {
            asset: [
              "An error",
              "Then some\nThis is truncated",
            ],
          }
        )

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .raises(client_error(response_body))

        time_freeze do
          @syncer.enqueue_updates([file])
          @syncer.wait!
        end
      end

      def test_log_api_errors_with_invalid_response_body
        mock_context_error_message
        @ctx.expects(:error).with(<<~EOS.chomp)
          12:30:59 {{red:ERROR }} {{>}} {{blue:update sections/footer.liquid}}:
            message
          EOS

        @syncer.start_threads
        file = @theme["sections/footer.liquid"]

        response_body = JSON.generate(
          errors: {
            message: "oops",
          }
        )

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .raises(client_error(response_body))

        time_freeze do
          @syncer.enqueue_updates([file])
          @syncer.wait!
        end
      end

      def test_log_when_an_error_is_fixed
        mock_context_error_message
        mock_context_fix_message

        file = @theme["sections/footer.liquid"]
        client_success = [200, {}, {}]

        ShopifyCLI::AdminAPI.stubs(:rest_request)
          .raises(client_error)
          .then
          .returns(client_success)

        @syncer.checksums["sections/footer.liquid"] = "initial"
        @syncer.start_threads

        # Assert an error message
        @ctx.expects(:error).with(<<~EOS.chomp)
          12:30:59 {{red:ERROR }} {{>}} {{blue:update sections/footer.liquid}}:
            message
          EOS
        file.stubs(checksum: "modified")
        time_freeze do
          @syncer.enqueue_updates([file])
          @syncer.wait!
        end

        # Assert a single fix message
        @ctx.expects(:puts).with("12:30:59 {{cyan:Fixed }} {{>}} {{blue:update sections/footer.liquid}}").once
        file.stubs(checksum: "initial")
        time_freeze do
          @syncer.enqueue_updates([file])
          @syncer.enqueue_updates([file])
          @syncer.wait!
        end
      end

      def test_delays_reporting_errors
        @syncer.start_threads
        file = @theme["sections/footer.liquid"]

        response_body = JSON.generate(
          errors: {
            asset: [
              "An error",
              "Then some",
            ],
          }
        )

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .raises(client_error(response_body))

        @ctx.expects(:error).never
        mock_context_error_message

        @syncer.lock_io!

        time_freeze do
          @syncer.enqueue_updates([file])
          @syncer.wait!
        end

        # Assert @ctx.puts was not called
        mocha_verify

        @ctx.expects(:error).with(<<~EOS.chomp)
          12:30:59 {{red:ERROR }} {{>}} {{blue:update sections/footer.liquid}}:
            An error
            Then some
        EOS
        @syncer.unlock_io!
      end

      def test_enqueue_invalid_method
        file = mock
        error = assert_raises(ArgumentError) { @syncer.send(:enqueue, :shutdown, file) }

        expected_error = "method 'shutdown' cannot be queued"
        actual_error = error.message

        assert_equal(expected_error, actual_error)
      end

      def test_broken_file_when_file_is_broken
        file = stub(relative_path: "templates/index.json", checksum: "AAAABBBCCC")
        @syncer.stubs(:checksums).returns({ "templates/index.json" => "AAAABBBCCC" })
        @syncer.stubs(:error_checksums).returns(["AAAABBBCCC"])

        assert(@syncer.broken_file?(file))
      end

      def test_broken_file_when_file_is_not_broken
        file = stub(relative_path: "templates/index.json", checksum: "AAAABBBCCC")
        @syncer.stubs(:checksums).returns({ "templates/index.json" => "AAAABBBCCC" })
        @syncer.stubs(:error_checksums).returns([])

        refute(@syncer.broken_file?(file))
      end

      # ASYNC BATCH

      private

      def time_freeze(&block)
        time = Time.local(2000, 1, 1, 12, 30, 59)
        Timecop.freeze(time, &block)
      end

      def mock_context_error_message
        @ctx.stubs(:message)
          .with("theme.serve.operation.status.error")
          .returns("ERROR")
      end

      def mock_context_fix_message
        @ctx.stubs(:message)
          .with("theme.serve.operation.status.fixed")
          .returns("Fixed")
      end

      def client_error(response_body = default_response_body)
        ShopifyCLI::API::APIRequestClientError.new("message", response: mock(body: response_body))
      end

      def default_response_body
        JSON.generate(errors: {})
      end

      def removed_json_file
        @removed_json_file ||= File.new("templates/removed.json", root)
      end

      def removed_css_file
        @removed_css_file ||= File.new("assets/removed.css", root)
      end

      def root
        @root ||= Pathname.new(ShopifyCLI::ROOT)
      end
    end
  end
end
