# frozen_string_literal: true

module Theme
  module Models
    module SpecificationHandlers
      class Theme
        REQUIRED_FOLDERS = %w(config layout sections templates).map { |folder| "#{folder}/" }

        def initialize(root)
          Dir.chdir(root) do
            self.folders = Dir["*/"] + Dir["templates/*/"]
          end
        end

        def valid?
          validate
          missing_folders.empty?
        end

        private

        attr_accessor :folders
        attr_accessor :missing_folders

        def validate
          self.missing_folders = REQUIRED_FOLDERS - folders
        end
      end
    end
  end
end
