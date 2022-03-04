require "test_helper"
require "timecop"

module ShopifyCLI
  module Core
    class MonorailTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::Core::Monorail.metadata = {}
      end

      def teardown
        ShopifyCLI::Core::Monorail.metadata = {}
        super
      end

      def test_full_command
        # Given
        create_subcommand_registry = mock("create_subcommand_registry")
        create_command = mock("create_command")
        create_command.stubs(:subcommand_registry)
          .returns(create_subcommand_registry)
        rails_subcommand_registry = mock("rails_subcommand_registry")
        rails_command = mock("rails_command")
        rails_command.stubs(:subcommand_registry).returns(rails_subcommand_registry)
        create_subcommand_registry
          .stubs(:lookup_command)
          .with("rails")
          .returns([rails_command, "rails"])
        rails_subcommand_registry
          .stubs(:lookup_command)
          .returns(nil)

        # When
        got = Core::Monorail.full_command(create_command, ["rails"], resolved_command: ["create"])
        
        # Then
        assert_equal ["create", "rails"], got
      end

      def test_log_event_contains_schema_and_payload_values
        enable_reporting(true)
        ShopifyCLI::Shopifolk.expects(:acting_as_shopify_organization?).returns(true)
        Timecop.freeze do |time|
          this_time = (time.utc.to_f * 1000).to_i
          stub_request(:post, Monorail::ENDPOINT_URI)
            .with(
              headers: {
                'Content-Type': "application/json; charset=utf-8",
                'X-Monorail-Edge-Event-Created-At-Ms': this_time.to_s,
                'X-Monorail-Edge-Event-Sent-At-Ms': this_time.to_s,
              },
              body: JSON.dump({
                schema_id: ShopifyCLI::Core::Monorail::INVOCATIONS_SCHEMA,
                payload: {
                  project_type: "fake",
                  command: "testcommand",
                  args: "arg argtwo",
                  time_start: this_time,
                  time_end: this_time,
                  total_time: 0,
                  success: true,
                  error_message: nil,
                  uname: RbConfig::CONFIG["host"],
                  cli_version: ShopifyCLI::VERSION,
                  ruby_version: RUBY_VERSION,
                  is_employee: true,
                  api_key: "apikey",
                  partner_id: 42,
                  metadata: "{\"foo\":\"identifier\"}",
                },
              })
            )
            .to_return(status: 200)

          ShopifyCLI::Core::Monorail.log("testcommand", %w(arg argtwo)) do
            ShopifyCLI::Core::Monorail.metadata[:foo] = "identifier"
            "This is the block and result"
          end
        end
      end

      def test_log_event_handles_errors
        enable_reporting(true)
        ShopifyCLI::Shopifolk.expects(:acting_as_shopify_organization?).returns(false)
        Timecop.freeze do |time|
          this_time = (time.utc.to_f * 1000).to_i
          stub_request(:post, Monorail::ENDPOINT_URI)
            .with(
              headers: {
                'Content-Type': "application/json; charset=utf-8",
                'X-Monorail-Edge-Event-Created-At-Ms': this_time.to_s,
                'X-Monorail-Edge-Event-Sent-At-Ms': this_time.to_s,
              },
              body: JSON.dump({
                schema_id: ShopifyCLI::Core::Monorail::INVOCATIONS_SCHEMA,
                payload: {
                  project_type: "fake",
                  command: "testcommand",
                  args: "arg argtwo",
                  time_start: this_time,
                  time_end: this_time,
                  total_time: 0,
                  success: false,
                  error_message: "test error",
                  uname: RbConfig::CONFIG["host"],
                  cli_version: ShopifyCLI::VERSION,
                  ruby_version: RUBY_VERSION,
                  is_employee: false,
                  api_key: "apikey",
                  partner_id: 42,
                },
              })
            )
            .to_return(status: 200)

          begin
            ShopifyCLI::Core::Monorail.log("testcommand", %w(arg argtwo)) do
              raise "test error"
            end
          rescue
          end
        end
      end

      def test_log_returns_the_result_after_sending_monorail_events
        enable_reporting(true)
        Net::HTTP.expects(:start).once

        result = ShopifyCLI::Core::Monorail.log("testcommand", %w(arg argtwo)) { "This is the block and result" }
        assert_equal("This is the block and result", result)
      end

      def test_log_returns_the_result_if_not_sending_monorail_events
        ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(false)
        ShopifyCLI::DB.stubs(:get).with(:organization_id).returns(42)

        enable_reporting(false)
        Net::HTTP.expects(:start).never

        result = ShopifyCLI::Core::Monorail.log("testcommand", %w(arg argtwo)) { "This is the block and result" }
        assert_equal("This is the block and result", result)
      end

      def test_log_sends_monorail_event_and_raises_exception_if_block_raises_exception
        ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(false)
        ShopifyCLI::DB.stubs(:get).with(:organization_id).returns(42)

        enable_reporting(true)
        Net::HTTP.expects(:start).once

        assert_raises Exception do
          ShopifyCLI::Core::Monorail.log("testcommand", %w(arg argtwo)) { raise Exception }
        end
      end

      def test_log_doesnt_send_monorail_event_if_not_enabled
        ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(false)
        ShopifyCLI::DB.stubs(:get).with(:organization_id).returns(42)

        enable_reporting(false)
        Net::HTTP.expects(:start).never

        ShopifyCLI::Core::Monorail.log("testcommand", %w(arg argtwo)) { "This is the block and result" }
      end

      def test_log_send_event_returns_result_if_monorail_returns_not_200
        ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(false)
        ShopifyCLI::DB.stubs(:get).with(:organization_id).returns(42)

        enable_reporting(true)
        stub_request(:post, Monorail::ENDPOINT_URI).to_return(status: 500)

        result = ShopifyCLI::Core::Monorail.log("testcommand", %w(arg argtwo)) { "This is the block and result" }
        assert_equal("This is the block and result", result)
      end

      def test_log_send_event_returns_result_if_timeout_occurs
        ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(false)
        ShopifyCLI::DB.stubs(:get).with(:organization_id).returns(42)

        enable_reporting(true)
        stub_request(:post, Monorail::ENDPOINT_URI).to_timeout

        result = ShopifyCLI::Core::Monorail.log("testcommand", %w(arg argtwo)) { "This is the block and result" }
        assert_equal("This is the block and result", result)
      end

      private

      def enable_reporting(enabled)
        Environment.expects(:send_monorail_events?).returns(enabled)
        ReportingConfigurationController.stubs(:check_or_prompt_report_automatically).returns(enabled)
      end
    end
  end
end
