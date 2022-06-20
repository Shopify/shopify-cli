# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/theme_admin_api_throttler/put_request"
require "shopify_cli/theme/theme_admin_api_throttler/bulk"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class BulkJobTest < Minitest::Test
        def setup
          super

          root = ShopifyCLI::ROOT + "/test/fixtures/theme"
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
          @admin_api = ThemeAdminAPI.new(@ctx, @theme.shop)
        end

        def test_perform_success
          files = [generate_put_request("file1.txt")]
          @job = BulkJob.new(@ctx, bulk(files: files))
          resp_body = {
            "results" => [
              {
                "code" => 200,
                "body" => {
                  "asset" => {
                    "key" => "file1.txt",
                  },
                },
              },
            ],
          }
          ShopifyCLI::AdminAPI
            .expects(:rest_request)
            .with(
              @ctx,
              shop: @theme.shop,
              path: "themes/#{@theme.id}/assets/bulk.json",
              method: "PUT",
              api_version: "unstable",
              body: JSON.generate({
                assets: [
                  { key: "file1.txt", value: "file1.txt" },
                ],
              })
            ).returns(
              [
                207,
                resp_body,
                {},
              ]
            )
          @ctx.expects(:debug)
            .with("[BulkJob] asset saved: file1.txt")
            .once
          @ctx.expects(:puts)
            .with(resp_body["results"].first["body"])
          @job.perform!
        end

        def test_suggest_stable_flag_when_bulk_request_error
          files = [generate_put_request("file1.txt")]
          @job = BulkJob.new(@ctx, bulk(files: files))
          ShopifyCLI::AdminAPI
            .expects(:rest_request)
            .with(
              @ctx,
              shop: @theme.shop,
              path: "themes/#{@theme.id}/assets/bulk.json",
              method: "PUT",
              api_version: "unstable",
              body: JSON.generate({
                assets: [
                  { key: "file1.txt", value: "file1.txt" },
                ],
              })
            ).returns(
              [
                400,
                {},
                {},
              ]
            )
          @ctx.expects(:puts)
            .with(@ctx.message("theme.stable_flag_suggestion"))
            .once
          @job.perform!
        end

        def test_retry_when_asset_update_error
          files = [generate_put_request("file1.txt")]
          bulker = bulk(files: files)
          @job = BulkJob.new(@ctx, bulker)
          bulker.expects(:enqueue).times(5)

          (BulkJob::MAX_RETRIES + 1).times do |request_num|
            ShopifyCLI::AdminAPI
              .expects(:rest_request)
              .with(
                @ctx,
                shop: @theme.shop,
                path: "themes/#{@theme.id}/assets/bulk.json",
                method: "PUT",
                api_version: "unstable",
                body: JSON.generate({
                  assets: [
                    { key: "file1.txt", value: "file1.txt" },
                  ],
                })
              ).returns(
                [
                  207,
                  {
                    "results" => [
                      {
                        "code" => 422,
                        "body" => {
                          "errors" => {
                            "asset" => "Something is wrong with this file!!!",
                          },
                        },
                      },
                    ],
                  },
                  {},
                ]
              )
            if request_num == BulkJob::MAX_RETRIES + 1
              @ctx.expects(:debug)
                .never
              @ctx.expects(:error).once
            else
              @ctx.expects(:debug)
                .with("[BulkJob] asset error: file1.txt")
            end
            @job.perform!
          end
        end

        private

        def bulk(files:)
          stub(
            "Bulk",
            ready?: true,
            consume_put_requests: files,
            admin_api: @admin_api,
            enqueue: nil,
          )
        end

        def generate_put_request(name)
          req_body = request_body(name)
          path = "themes/#{@theme.id}/assets.json"
          req = PutRequest.new(path, req_body) do |status, body, _response|
            if status == 200
              @ctx.puts(body)
            else
              @ctx.error(body)
            end
          end
          req
        end

        def request_body(name)
          JSON.generate(
            asset: {
              key: name,
              value: name,
            }
          )
        end
      end
    end
  end
end
