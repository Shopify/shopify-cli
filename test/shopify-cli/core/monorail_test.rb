require 'test_helper'

module ShopifyCli
  module Core
    class MonorailTest < MiniTest::Test
      def setup
        super
        ShopifyCli::Git.stubs(:sha).returns("bb6f42193239a248f054e5019e469bc75f3adf1b")
        CLI::UI::Prompt.stubs(:confirm).returns(true)
      end

      def test_log_prompts_for_consent_and_saves_answer
        enabled_and_consented(true, nil)
        ShopifyCli::Config.expects(:get_section).with('analytics').returns(stub("key?" => false))
        CLI::UI::Prompt.expects(:confirm).returns(true)
        ShopifyCli::Config.expects(:set).with('analytics', 'enabled', true)
        Net::HTTP.expects(:start).never

        ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
      end

      def test_log_doesnt_prompt_for_consent_if_not_enabled
        enabled_and_consented(false, nil)
        ShopifyCli::Config.expects(:get_section).never
        CLI::UI::Prompt.expects(:confirm).never
        Net::HTTP.expects(:start).never

        ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
      end

      def test_log_doesnt_prompt_for_consent_if_already_answered
        enabled_and_consented(true, false)
        ShopifyCli::Config.expects(:get_section).with('analytics').returns(stub("key?" => true))
        CLI::UI::Prompt.expects(:confirm).never
        Net::HTTP.expects(:start).never

        ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
      end

      def test_log_event_contains_schema_and_payload_values
        enabled_and_consented(true, true)
        stub_request(:post, Monorail::ENDPOINT_URI).to_return(status: 200)

        JSON.expects(:dump).with(
          has_entries(
            schema_id: ShopifyCli::Core::Monorail::INVOCATIONS_SCHEMA,
            payload: has_entries(
              cli_sha: "bb6f42193239a248f054e5019e469bc75f3adf1b",
              uname: instance_of(String),
              args: "testcommand arg argtwo",
              timestamp: instance_of(String),
              duration: instance_of(Float),
              result: ShopifyCli::Core::Monorail::SUCCESS_SENTINEL
            )
          )
        )

        ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
      end

      def test_log_returns_the_result_after_sending_monorail_events
        enabled_and_consented(true, true)
        Net::HTTP.expects(:start).once

        result = ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
        assert_equal('This is the block and result', result)
      end

      def test_log_returns_the_result_if_not_sending_monorail_events
        enabled_and_consented(true, false)
        Net::HTTP.expects(:start).never

        result = ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
        assert_equal('This is the block and result', result)
      end

      def test_log_sends_monorail_event_and_raises_exception_if_block_raises_exception
        enabled_and_consented(true, true)
        Net::HTTP.expects(:start).once

        assert_raises Exception do
          ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { raise Exception }
        end
      end

      def test_log_doesnt_send_monorail_event_if_not_enabled
        enabled_and_consented(false, true)
        Net::HTTP.expects(:start).never

        ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
      end

      def test_log_doesnt_send_monorail_event_if_enabled_but_not_consented
        enabled_and_consented(true, false)
        Net::HTTP.expects(:start).never

        ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
      end

      def test_log_send_event_returns_result_if_monorail_returns_not_200
        enabled_and_consented(true, true)
        stub_request(:post, Monorail::ENDPOINT_URI).to_return(status: 500)

        result = ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
        assert_equal('This is the block and result', result)
      end

      def test_log_send_event_returns_result_if_timeout_occurs
        enabled_and_consented(true, true)
        stub_request(:post, Monorail::ENDPOINT_URI).to_timeout

        result = ShopifyCli::Core::Monorail.log('testcommand', %w(arg argtwo)) { 'This is the block and result' }
        assert_equal('This is the block and result', result)
      end

      private

      def enabled_and_consented(enabled, consented)
        ShopifyCli::Context.any_instance.stubs(:system?).returns(enabled)
        ShopifyCli::Config.stubs(:get_bool).with('analytics', 'enabled').returns(consented)
      end
    end
  end
end
