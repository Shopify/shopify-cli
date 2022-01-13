# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ScriptConfig
        attr_reader :content, :version, :title, :description, :configuration_ui, :configuration, :filename

        REQUIRED_FIELDS = %w(version title)

        def initialize(content:, filename:)
          @filename = filename
          validate_content!(content)
          @content = content
          @version = @content["version"].to_s
          @title = @content["title"]
          @description = @content["description"]
          @configuration_ui = @content.fetch("configurationUi", true)
          @configuration = @content["configuration"]
        end

        private

        def validate_content!(content)
          REQUIRED_FIELDS.each do |field|
            if content[field].nil?
              raise Errors::MissingScriptConfigFieldError.new(field: field, filename: filename)
            end
          end
        end
      end
    end
  end
end
