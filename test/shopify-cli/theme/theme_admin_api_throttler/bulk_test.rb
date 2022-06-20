# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/theme_admin_api_throttler/put_request"
require "shopify_cli/theme/theme_admin_api_throttler/bulk"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class BulkTest < Minitest::Test
        MULTIPLE_THREADS = 3

        def setup
          super
          root = ShopifyCLI::ROOT + "/test/fixtures/theme"

          ShopifyCLI::DB
            .stubs(:get)
            .with(:development_theme_id)
            .returns("12345678")

          # Avoid rest_request call
          ShopifyCLI::Theme::ThemeAdminAPIThrottler::BulkJob
            .any_instance
            .stubs(:rest_request)
            .returns(temp_bulk_response)

          ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("dev-theme-server-store.myshopify.com")

          @ctx = TestHelpers::FakeContext.new(root: root)
          @theme = Theme.new(@ctx, root: root)
          @admin_api = ThemeAdminAPI.new(@ctx, @theme.shop)
        end

        def test_batch_bytesize_upper_bound_with_multiple_threads
          @bulk = FakeBulk.new(@ctx, @admin_api, pool_size: MULTIPLE_THREADS)

          request_1 = generate_put_request("file1.txt", Bulk::MAX_BULK_BYTESIZE / 3)
          request_2 = generate_put_request("file2.txt", Bulk::MAX_BULK_BYTESIZE / 3)
          request_3 = generate_put_request("file3.txt", Bulk::MAX_BULK_BYTESIZE + 1)

          [request_1, request_2, request_3].each do |request|
            @bulk.enqueue(request)
          end

          @bulk.timeout!
          @bulk.send(:wait_put_requests)

          assert_equal(2, @bulk.consume_put_requests_calls)
          assert_equal([request_1.size + request_2.size, request_3.size], @bulk.sizes)
          @bulk.shutdown
        end

        def test_batch_bytesize_upper_bound_with_single_thread
          @bulk = FakeBulk.new(@ctx, @admin_api)

          request_1 = generate_put_request("file1.txt", Bulk::MAX_BULK_BYTESIZE + 2)
          request_2 = generate_put_request("file2.txt", Bulk::MAX_BULK_BYTESIZE + 3)
          request_3 = generate_put_request("file3.txt", Bulk::MAX_BULK_BYTESIZE + 4)

          [request_1, request_2, request_3].each do |request|
            @bulk.enqueue(request)
          end

          @bulk.timeout!
          @bulk.send(:wait_put_requests)

          assert_equal(3, @bulk.consume_put_requests_calls)
          assert_equal([request_1.size, request_2.size, request_3.size], @bulk.sizes)
          @bulk.shutdown
        end

        def test_batch_num_files_upper_bound_with_single_thread
          @bulk = FakeBulk.new(@ctx, @admin_api)

          Bulk::MAX_BULK_FILES.times do |n|
            @bulk.enqueue(generate_put_request("file#{n}.txt", 100_000))
          end

          @bulk.timeout!
          @bulk.send(:wait_put_requests)

          assert_equal(1, @bulk.consume_put_requests_calls)
          assert_equal([2_000_000], @bulk.sizes)
          @bulk.shutdown
        end

        def test_batch_num_files_upper_bound_with_multiple_threads
          @bulk = FakeBulk.new(@ctx, @admin_api, pool_size: MULTIPLE_THREADS)

          num_requests = Bulk::MAX_BULK_FILES << 1

          num_requests.times do |n|
            @bulk.enqueue(generate_put_request("file#{n}.txt", 10_000))
          end

          @bulk.timeout!
          @bulk.send(:wait_put_requests)

          assert_equal(2, @bulk.consume_put_requests_calls)
          assert_equal([Bulk::MAX_BULK_FILES * 10_000, Bulk::MAX_BULK_FILES * 10_000], @bulk.sizes)
          @bulk.shutdown
        end

        def test_batch_big_test_with_multiple_threads
          @bulk = FakeBulk.new(@ctx, @admin_api, pool_size: MULTIPLE_THREADS)

          files = 5.times.map do |i|
            size = (Bulk::MAX_BULK_BYTESIZE / 2) - 1000
            generate_put_request("file#{i}.txt", size + i)
          end

          files.each { |file| @bulk.enqueue(file) }

          @bulk.timeout!
          @bulk.send(:wait_put_requests)

          assert_equal(3, @bulk.consume_put_requests_calls)
          assert_equal([
            files[0].size + files[1].size,
            files[2].size + files[3].size,
            files[4].size], @bulk.sizes)
          @bulk.shutdown
        end

        private

        def generate_put_request(name, size)
          req_body = request_body(name)
          path = "themes/#{@theme.id}/assets.json"
          req = PutRequest.new(path, req_body) do |status, body, _response|
            if status == 200
              @ctx.puts(body)
            else
              @ctx.error(body)
            end
          end
          req.stubs(:size).returns(size)
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

        def temp_bulk_response
          [1234, [], {}]
        end

        class FakeBulk < Bulk
          attr_accessor :consume_put_requests_calls, :sizes

          def initialize(ctx, admin_api, pool_size: 20)
            super(ctx, admin_api, pool_size: pool_size)
            @consume_put_requests_calls = 0
            @is_queue_timeout = false
            @sizes = []
          end

          def consume_put_requests
            bulk_request = super
            @sizes << bulk_request.map(&:size).reduce(0, &:+)
            @consume_put_requests_calls += 1
            bulk_request
          end

          def timeout!
            @is_queue_timeout = true
          end
        end
      end
    end
  end
end
