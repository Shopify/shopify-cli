# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Messages
      def assert_message_output(io:, expected_content:)
        all_output = io.join

        Array(expected_content).each do |expected|
          assert_includes all_output, CLI::UI.fmt(expected)
        end
      end

      def capture_io_and_assert_raises(exception_class)
        io = []
        io << capture_io do
          exception = assert_raises(exception_class) { yield }
          io << CLI::UI.fmt(exception.message.gsub("{{x}} ", ""))
        end
      end
    end
  end
end
