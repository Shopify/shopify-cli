# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class DependencyError < StandardError
        def initialize(name)
          super("No dependency support for #{name}")
        end
      end
    end
  end
end
