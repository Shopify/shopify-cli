# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class FakeConfigUiRepository
        def initialize
          @cache = {}
        end

        def create_config_ui(filename, content)
          @cache[filename] = Domain::ConfigUi.new(
            filename: filename,
            content: content,
          )
        end

        def get_config_ui(filename)
          @cache[filename]
        end
      end
    end
  end
end
