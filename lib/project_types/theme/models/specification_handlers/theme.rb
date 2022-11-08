# frozen_string_literal: true

module Theme
  module Models
    module SpecificationHandlers
      class Theme
        REQUIRED_FOLDERS = %w(config layout sections templates templates/customers).map { |folder| "#{folder}/" }
        OPTIONAL_FOLDERS = %w(assets locales snippets).map { |folder| "#{folder}/" }

        attr_accessor :folders
        attr_accessor :missing_folders
        attr_accessor :superfluous_folders

        def initialize(root)
          return if root.nil?

          Dir.chdir(root) do
            self.folders = Dir["*/"] + Dir["templates/*/"]
          end
        end

        def valid?
          self.validate
          self.superfluous_folders.empty? && self.missing_folders.empty?
        end

        private

        def validate
          self.superfluous_folders = self.folders - REQUIRED_FOLDERS - OPTIONAL_FOLDERS
          self.missing_folders = REQUIRED_FOLDERS - self.folders
        end
      end
    end
  end
end
