# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class Syncer
      class Operation < Struct.new(:method, :file)
        def to_s
          "#{method} #{file&.relative_path}"
        end
      end
    end
  end
end
