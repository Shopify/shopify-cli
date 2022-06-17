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
          @bulk = BulkMock.new(@admin_api, pool_size: MULTIPLE_THREADS)

          file1 = generate_put_request("file1", 30_010)
          file2 = generate_put_request("file2", 60_020)
          file3 = generate_put_request("file3", 5_242_880) # exactly max bytesize

          [file1, file2, file3].each do |r|
            @bulk.enqueue(r)
          end

          assert(@bulk.num_calls, 2)
          assert(@bulk.sizes, [90_030, 5_242_880])
          @bulk.shutdown
        end

        def test_batch_bytesize_upper_bound_with_single_thread
          @bulk = BulkMock.new(@admin_api)

          file1 = generate_put_request("file1", 5_242_802)
          file2 = generate_put_request("file2", 5_242_803)
          file3 = generate_put_request("file3", 5_242_804) # exactly max bytesize

          [file1, file2, file3].each do |r|
            @bulk.enqueue(r)
          end

          assert(@bulk.num_calls, 3)
          assert(@bulk.sizes, [5_242_802, 5_242_803, 5_242_804])
          @bulk.shutdown
        end

        def test_batch_num_files_upper_bound_with_single_thread
          @bulk = BulkMock.new(@admin_api)

          Bulk::MAX_BULK_FILES.times { |n|
            file = generate_put_request("file#{n}", 100_000)
            @bulk.enqueue(file)
          }

          assert(@bulk.num_calls, 1)
          assert(@bulk.sizes, [3_000_000])
          @bulk.shutdown
        end

        def test_batch_num_files_upper_bound_with_multiple_threads
          @bulk = BulkMock.new(@admin_api, pool_size: MULTIPLE_THREADS)

          num_requests = Bulk::MAX_BULK_FILES << 1

          num_requests.times { |n|
            file = generate_put_request("file#{n}", 10_000)
            @bulk.enqueue(file)
          }

          assert(@bulk.num_calls, 2)
          assert(@bulk.sizes, [Bulk::MAX_BULK_FILES * 10_000, Bulk::MAX_BULK_FILES * 10_000])
          @bulk.shutdown
        end

        def test_batch_big_test_with_multiple_threads
          @bulk = BulkMock.new(@admin_api, pool_size: MULTIPLE_THREADS)

          5.times { |n|
            file = generate_put_request("file#{n}", 3_565_210 + n)
            @bulk.enqueue(file)
          }

          assert(@bulk.num_calls, 5)
          assert(@bulk.sizes, [3_565_211, 3_565_212, 3_565_213, 3_565_214, 3_565_215])
          @bulk.shutdown
        end

        private

        def generate_put_request(name, size)
          body = request_body(name, size)
          path = "themes/#{@theme.id}/assets.json"
          request = stub(
            "PutRequest",
            name: name, # debugging
            method: "PUT",
            body: body,
            size: size,
            path: path,
            bulk_path: path.gsub(/.json$/, "/bulk.json"),
            block: nil,
          )
          request
        end

        def request_body(name, size)
          JSON.generate(
            asset: {
              key: "#{name}.txt",
              value: "#{name}",
            }
          )
        end

        def temp_bulk_response
          [1234, [], {}]
        end

        class BulkMock < Bulk
          attr_accessor :num_calls, :sizes

          def initialize(admin_api, pool_size: 1)
            super(admin_api, pool_size: pool_size)
            @num_calls = 0
            @sizes = []
          end

          def consume_put_requests
            bulk_request = super # pretty hacky, but it appears to work and allows me to profile nicely

            @sizes += bulk_request.map(&:size).reduce(:+).to_i
            @num_calls += 1
          end
        end
      end
    end
  end
end
