# typed: ignore
# frozen_string_literal: true
require "test_helper"

module Extension
  module Models
    module SpecificationHandlers
      autoload(:Default, "project_types/extension/models/specification_handlers/default")
    end
  end

  module ExtensionTestHelpers
    class TestExtension < Models::SpecificationHandlers::Default
      IDENTIFIER = "TEST_EXTENSION"

      def graphql_identifier
        "TEST_EXTENSION_GQL"
      end

      def tagline
        "An extension for testing"
      end

      def config(_context)
        {
          title: "A Test Extension Title",
          field: "field_for_test_extension",
        }
      end
    end
  end
end
