# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    class TestExtension < Models::Type
      IDENTIFIER = 'TEST_EXTENSION'

      def name
        'Test Extension'
      end

      def tagline
        'An extension for testing'
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
