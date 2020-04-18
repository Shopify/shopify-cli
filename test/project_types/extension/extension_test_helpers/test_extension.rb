# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    class TestExtension < Models::Type
      def identifier
        'TEST_EXTENSION'
      end

      def name
        'Test Extension'
      end

      def config(_context)
        {
          title: 'A Test Extension Title',
          field: 'field_for_test_extension'
        }
      end
    end
  end
end
