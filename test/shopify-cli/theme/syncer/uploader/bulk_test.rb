# frozen_string_literal: true

require "test_helper"

require "shopify_cli/theme/theme"
require "shopify_cli/theme/syncer/uploader/bulk"
require "shopify_cli/theme/syncer/uploader/bulk_item"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class BulkTest < Minitest::Test
          include TestHelpers::FakeDB

          def setup
            super
            root = ShopifyCLI::ROOT + "/test/fixtures/theme"

            stubs_cli_db(:shop, "dev-theme-server-store.myshopify.com")
            stubs_cli_db(:development_theme_id, "12345678")

            @ctx = TestHelpers::FakeContext.new(root: root)
            @theme = Theme.new(@ctx, root: root)
            @admin_api = stub(rest_request: [207, [], {}])
          end

          def test_batch_bytesize_upper_bound_with_multiple_threads
            bulk = Bulk.new(@ctx, @theme, @admin_api, pool_size: 1)
            bulk.stubs(:backoff_if_near_limit!)

            bulk_item_1 = bulk_item("config/settings_data.json", Bulk::MAX_BULK_BYTESIZE / 3)
            bulk_item_2 = bulk_item("sections/footer.liquid", Bulk::MAX_BULK_BYTESIZE / 3)
            bulk_item_3 = bulk_item("templates/blog.json", Bulk::MAX_BULK_BYTESIZE + 1)

            expect_job_request(2, bulk_item_1.size + bulk_item_2.size)
            expect_job_request(1, bulk_item_3.size)

            expect_job_response.twice
            expect_shutdown_message

            bulk.enqueue(bulk_item_1)
            bulk.enqueue(bulk_item_2)
            bulk.enqueue(bulk_item_3)
            bulk.shutdown
          end

          def test_batch_bytesize_upper_bound_with_single_thread
            bulk = bulk_instance

            bulk_item_1 = bulk_item("config/settings_data.json", Bulk::MAX_BULK_BYTESIZE + 2)
            bulk_item_2 = bulk_item("sections/footer.liquid", Bulk::MAX_BULK_BYTESIZE + 3)
            bulk_item_3 = bulk_item("templates/blog.json", Bulk::MAX_BULK_BYTESIZE + 4)

            expect_job_request(1, bulk_item_1.size)
            expect_job_request(1, bulk_item_2.size)
            expect_job_request(1, bulk_item_3.size)

            expect_job_response.times(3)
            expect_shutdown_message

            bulk.enqueue(bulk_item_1)
            bulk.enqueue(bulk_item_2)
            bulk.enqueue(bulk_item_3)
            bulk.shutdown
          end

          def test_batch_num_files_upper_bound_with_single_thread
            bulk = bulk_instance

            expect_job_request(10, 100)
            expect_shutdown_message

            Bulk::MAX_BULK_FILES.times do |n|
              bulk.enqueue(bulk_item("file#{n}.txt", 10))
            end

            bulk.shutdown
          end

          def test_batch_num_files_upper_bound_with_multiple_threads
            bulk = bulk_instance(pool_size: 2)

            expect_job_request(10, 100).twice
            expect_shutdown_message

            number_of_files = Bulk::MAX_BULK_FILES * 2
            number_of_files
              .times do |n|
                bulk.enqueue(bulk_item("file#{n}.txt", 10))
              end

            bulk.shutdown
          end

          def test_batch_big_test_with_multiple_threads
            bulk = bulk_instance(pool_size: 2)

            files = 5
              .times
              .map do |i|
                bytesize = Bulk::MAX_BULK_BYTESIZE / 2 - 1000 + i
                bulk_item("file#{i}.txt", bytesize)
              end

            expect_job_request(2, files[0].size + files[1].size)
            expect_job_request(2, files[2].size + files[3].size)
            expect_job_request(1, files[4].size)
            expect_shutdown_message

            files.each { |file| bulk.enqueue(file) }

            bulk.shutdown
          end

          private

          def bulk_instance(pool_size: 1)
            bulk = Bulk.new(@ctx, @theme, @admin_api, pool_size: pool_size)
            bulk.stubs(:backoff_if_near_limit!)
            bulk
          end

          def bulk_item(file_name, size)
            file = @theme[file_name]

            item = BulkItem.new(file) do |status, body, _response|
              if status == 200
                @ctx.puts(body)
              else
                @ctx.error(body)
              end
            end

            item.stubs(:size).returns(size)
            item
          end

          def expect_job_request(size, bytesize)
            expect_debug_message(/\[BulkJob #\d+\] job request: size=#{size}, bytesize=#{bytesize}/)
          end

          def expect_job_response
            expect_debug_message(/\[BulkJob #\d+\] job response: http_status=207/)
          end

          def expect_shutdown_message
            expect_debug_message(/\[Bulk\] shutdown/)
          end

          def expect_debug_message(pattern)
            @ctx.expects(:debug).with { |message| message.match?(pattern) }
          end
        end
      end
    end
  end
end
