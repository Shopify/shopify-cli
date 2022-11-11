# frozen_string_literal: true

module Theme
  module Models
    module SpecificationHandlers
      class Theme
        REQUIRED_FOLDERS = %w(config layout sections templates)

        def initialize(root)
          @root = root
        end

        def valid?
          REQUIRED_FOLDERS.all? { |required_folder| Dir.exist?(File.join(@root, required_folder)) }
        end
      end
    end
  end
end
