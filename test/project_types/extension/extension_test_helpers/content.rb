# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Content
      def confirm_content_output(io:, expected_content:)
        all_output = io.join

        Array(expected_content).each do |expected|
          assert_includes all_output, CLI::UI.fmt(expected)
        end
      end
    end
  end
end
