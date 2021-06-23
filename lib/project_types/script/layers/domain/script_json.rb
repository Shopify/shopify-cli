# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ScriptJson
        attr_reader :filename, :content, :version, :title, :description, :configuration_ui, :configuration

        def initialize(filename:, content:)
          @filename = filename
          @content = content
          @version = @content["version"].to_s
          @title = @content["title"]
          @description = @content["description"]
          @configuration_ui = @content["configurationUi"]
          @configuration = @content["configuration"]
        end
      end
    end
  end
end
