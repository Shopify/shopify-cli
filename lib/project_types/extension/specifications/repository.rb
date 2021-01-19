module Extension
  module Specifications
    class Repository
      def all
        records = [{
          "type": "test_extension",
          "name": "Test Extension",
          "options": {
            "versioned": true,
            "management_experience": "cli",
            "registration_limit": 1,
            "internal_only": true
          },
          "features": {
            "argo": {
              "host": "admin"
            },
          },
          "overrides": {
            "approval_system": "NoOp"
          }
        }]

        records.map { |record| Specification.new(**record) }
      end

      def get(specification_identifier)
        all.first
      end
    end
  end
end
