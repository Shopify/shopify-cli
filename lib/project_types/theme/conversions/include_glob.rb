# frozen_string_literal: true

require_relative "base_glob"

module Theme
  module Conversions
    class IncludeGlob < BaseGlob
      class << self
        def options
          %w(-o --only)
        end
      end
    end
  end
end
