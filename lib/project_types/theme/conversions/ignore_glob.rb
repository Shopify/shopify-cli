# frozen_string_literal: true

require_relative "base_glob"

module Theme
  module Conversions
    class IgnoreGlob < BaseGlob
      class << self
        def options
          %w(-x --ignore)
        end
      end
    end
  end
end
