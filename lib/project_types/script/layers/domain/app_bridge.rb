# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class AppBridge
        attr_reader :create_path, :details_path

        def initialize(create_path:, details_path:)
          @create_path = create_path
          @details_path = details_path
        end
      end
    end
  end
end
