# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class FakeConfigUiRepository
        def initialize
          @cache = {}
        end

        def create(filename, content)
          @cache[filename] = Domain::ConfigUi.new(
            filename: filename,
            content: content,
          )
        end

        def get(filename)
          @cache[filename]
        end
      end
    end
  end
end
