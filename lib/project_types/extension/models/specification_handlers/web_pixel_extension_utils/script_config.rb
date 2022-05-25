# frozen_string_literal: true

module Extension
  module Models
    module SpecificationHandlers
      module WebPixelExtensionUtils
        class ScriptConfig
          attr_reader :content, :version, :configuration, :filename

          REQUIRED_FIELDS = %w(version)

          def initialize(content:, filename:)
            @filename = filename
            validate_content!(content)
            @content = content
            @version = @content["version"].to_s
            @configuration = @content["configuration"]
          end

          private

          def validate_content!(content)
            REQUIRED_FIELDS.each do |field|
              if content[field].nil?
                raise "invalid field:#{field}, filename:#{filename}"
              end
            end
          end
        end
      end
    end
  end
end
