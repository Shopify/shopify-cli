# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/syncer/uploader/bulk_job"
require "shopify_cli/theme/syncer/uploader/bulk_item"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class BulkJobTest < Minitest::Test
          include TestHelpers::FakeDB

          def setup
            super
            root = ShopifyCLI::ROOT + "/test/fixtures/theme"

            stubs_cli_db(:shop, "dev-theme-server-store.myshopify.com")
            stubs_cli_db(:development_theme_id, "12345678")

            @ctx = TestHelpers::FakeContext.new(root: root)
            @theme = Theme.new(@ctx, id: 1, root: root)
            @admin_api = ThemeAdminAPI.new(@ctx, @theme.shop)
          end

          def test_perform_success
            job = BulkJob.new(@ctx, bulk(items: [bulk_item], size: bulk_item.size))

            expect_admin_api_request.returns(
                [
                  207,
                  {
                    "results" => [
                      {
                        "code" => 200,
                        "body" => { "asset" => { "key" => "file1.txt" } },
                      },
                    ],
                  },
                  {},
                ]
              )

            expect_job_request(1, bulk_item.size)
            expect_job_response(207)
            expect_job_success(bulk_item.key)

            job.perform!
          end

          def test_suggest_stable_flag_when_bulk_request_error
            job = BulkJob.new(@ctx, bulk(items: [bulk_item], size: bulk_item.size))

            expect_admin_api_request.returns([400, {}, {}])

            expect_job_request(1, bulk_item.size)
            expect_job_response(400)

            @ctx.expects(:abort).with(@ctx.message("theme.stable_flag_suggestion"))

            job.perform!
          end

          def test_retry_when_asset_update_error
            bulk_instance = bulk(items: [bulk_item], size: bulk_item.size)
            job = BulkJob.new(@ctx, bulk_instance)
            key = bulk_item.key
            status = 422

            bulk_instance.expects(:enqueue).times(BulkJob::MAX_RETRIES)

            expect_job_request(1, bulk_item.size).times(1 + BulkJob::MAX_RETRIES)
            expect_job_response(207).at_least_once
            expect_job_error(key, status)

            (0...BulkJob::MAX_RETRIES).each do |i|
              expect_job_retry(key, status, i)
            end

            @ctx.expects(:error)
              .with("error: Oops! Something went wrong")
              .once

            (BulkJob::MAX_RETRIES + 1).times do |_i|
              expect_admin_api_request.returns(
                  [
                    207,
                    {
                      "results" => [
                        {
                          "code" => 422,
                          "body" => {
                            "errors" => {
                              "asset" => "Oops! Something went wrong",
                            },
                          },
                        },
                      ],
                    },
                    {},
                  ]
                )
              job.perform!
            end
          end

          def test_parse_responses
            body = {
              "results" => [
                {
                  "code" => 200,
                  "body" => { "asset" => { "key" => "templates/index.liquid" } },
                },
                {
                  "code" => 200,
                  "body" => { "asset" => { "key" => "icon-minus.liquid" } },
                },
              ],
            }

            actual = BulkJob.new(@ctx, bulk).send(:parse_responses, body)
            expected = [
              [200, { "asset" => { "key" => "templates/index.liquid" } }],
              [200, { "asset" => { "key" => "icon-minus.liquid" } }],
            ]

            assert_equal(expected, actual)
          end

          private

          def bulk(items: [], size: 0)
            stub(
              "Bulk",
              consume_bulk_items: [items, size],
              admin_api: @admin_api,
              theme: @theme,
              enqueue: nil,
              clean_in_progress_items: nil,
              wait_for_backoff!: nil,
              backoff_if_near_limit!: nil
            )
          end

          def bulk_item
            return @bulk_item if @bulk_item

            file_name = "file1.txt"
            file = @theme[file_name]

            @bulk_item = BulkItem.new(file) do |status, body, response|
              if status == 200
                @ctx.puts("success: #{body["asset"]["key"]}")
              else
                @ctx.error("error: #{response.response[:body].dig("errors", "asset")}")
              end
            end

            @bulk_item.stubs(:asset_hash).returns({
              key: file_name,
              value: file_name,
            })

            @bulk_item
          end

          def expect_job_request(size, bytesize)
            expect_debug_message(/job request: size=#{size}, bytesize=#{bytesize}/)
          end

          def expect_job_response(http_status)
            expect_debug_message(/job response: http_status=#{http_status}/)
          end

          def expect_job_success(key)
            expect_debug_message(/bulk item success \(item=#{key}\)/)
          end

          def expect_job_retry(key, status, retries)
            expect_debug_message(/bulk item error \(item=#{key}, status=#{status}, retries=#{retries}\)/)
          end

          def expect_job_error(key, status)
            expect_debug_message(/bulk item fatal error \(item=#{key}, status=#{status}\)/)
          end

          def expect_debug_message(pattern)
            @ctx.expects(:debug).with { |message| message.match?(/\[BulkJob #\d+\] #{pattern}/) }
          end

          def expect_admin_api_request
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
              )
          end
        end
      end
    end
  end
end
