# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class ChooseNextAvailablePortTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup

      def test_given_port_is_returned_when_available
        socket = mock.tap { |s| s.expects(:close).once }
        Socket.expects(:tcp).with("example.com", 12345, connect_timeout: 1).yields(socket).returns(true).once

        port = Tasks::ChooseNextAvailablePort.new(from: 12345, host: "example.com").call
        assert_predicate(port, :success?)
        assert_equal(12345, port.value)
      end

      def test_returns_next_available_port_if_given_port_is_taken
        socket = mock.tap { |s| s.expects(:close).twice }
        Socket.expects(:tcp).with("example.com", 12345, connect_timeout: 1).yields(socket).returns(false).once
        Socket.expects(:tcp).with("example.com", 12346, connect_timeout: 1).yields(socket).returns(true).once

        port = Tasks::ChooseNextAvailablePort.new(from: 12345, host: "example.com").call
        assert_predicate(port, :success?)
        assert_equal(12346, port.value)
      end

      def test_aborts_after_all_port_in_range_have_been_scanned
        socket = mock.tap { |s| s.expects(:close).times(3) }
        Socket.expects(:tcp).with("example.com", 12345, connect_timeout: 1).yields(socket).returns(false)
        Socket.expects(:tcp).with("example.com", 12346, connect_timeout: 1).yields(socket).returns(false)
        Socket.expects(:tcp).with("example.com", 12347, connect_timeout: 1).yields(socket).returns(false)

        port = Tasks::ChooseNextAvailablePort.new(from: 12345, host: "example.com", to: 12347).call
        assert_predicate(port, :failure?)
        port.error.tap do |error|
          assert_kind_of(ArgumentError, error)
          assert_equal("Ports between 12345 and 12347 are unavailable", error.message)
        end
      end

      def test_scans_10_ports_by_default
        assert_equal 12355, Tasks::ChooseNextAvailablePort.new(from: 12345).to
      end
    end
  end
end
