require 'test_helper'

module ShopifyCli
  class MonorailTest < MiniTest::Test
    include TestHelpers::Constants

    DELAY = 10

    def setup
      super
      @events = Tempfile.open('monorail_log')
      @mtime = Tempfile.open('events_mtime')
      redefine_constant(ShopifyCli, :EVENTS_FILE, @events)
      redefine_constant(ShopifyCli, :EVENTS_MTIME, @mtime)
      Monorail.monorail = nil
      Monorail.events = nil
      ShopifyCli::Config.stubs(:get_section).with('analytics').returns('enabled' => true)
      Helpers::Async.stubs(:in_thread).yields
    end

    def test_log_does_not_write_when_disabled_by_config
      Config.stubs(:get).returns('false')
      Monorail.log.invocation('test', ['arg'])
      assert_equal 0, @events.size
    end

    def test_log_does_not_write_when_not_system
      Util.stubs(:system?).returns(false)
      Monorail.log.invocation('test', ['arg'])
      assert_equal 0, @events.size
    end

    def test_log_promopts_for_consent
      Util.stubs(:system?).returns(true)
      Config.stubs(:get_section).returns({})
      CLI::UI::Prompt.expects(:confirm).returns(true)
      Config.expects(:set).with('analytics', 'enabled', true)
      Monorail.log.invocation('test', ['arg'])
    end

    def test_log_writes_to_file_when_enabled
      Util.stubs(:system?).returns(true)
      Config.stubs(:get).returns('true')
      ShopifyCli::Log.any_instance.expects(:write)
      Monorail.log.invocation('test', ['arg'])
    end

    def test_send_events_does_not_send_when_disabled
      write_events
      Config.stubs(:get).returns('false')
      Monorail.expects(:produce).never
      Monorail.send_events
    end

    def test_send_events_sends_when_enabled_and_consented
      write_events
      Util.stubs(:system?).returns(true)
      Config.stubs(:get).returns('true')
      Monorail.expects(:produce)
      Monorail.send_events
    end

    def test_send_events_sends_only_new_events
      write_events(3)
      File.write(@mtime, @_events.first[:timestamp])
      Util.stubs(:system?).returns(true)
      Config.stubs(:get).returns('true')
      Monorail.expects(:produce).twice
      Monorail.send_events
      assert_equal @_events.last[:timestamp], File.read(@mtime)
    end

    def write_events(count = 1)
      @_events = []
      count.times do |i|
        event = { timestamp: (Time.now - DELAY - count + i).utc.to_s }
        @_events << event
        File.write(@events, JSON.dump(payload: event) + "\n", mode: 'a')
      end
    end
  end
end
