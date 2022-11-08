# frozen_string_literal: true

module Theme
  module Models
    module SpecificationHandlers
      class Theme
        REQUIRED_ROOT_FOLDERS = %w(config layout sections templates).map { |folder| "#{folder}/" }
        OPTIONAL_ROOT_FOLDERS = %w(assets locales snippets).map { |folder| "#{folder}/" }
        REQUIRED_TEMPLATES_FOLDERS = %w(customers).map { |folder| "templates/#{folder}/" }

        attr_accessor :root_folders
        attr_accessor :templates_folders
        attr_accessor :superfluous_root_folders
        attr_accessor :missing_root_folders
        attr_accessor :superfluous_templates_folders
        attr_accessor :missing_templates_folders

        def initialize(root)
          return if root.nil?

          Dir.chdir(root) do
            self.root_folders, self.templates_folders = Dir["*/"], Dir["templates/*/"]
          end
        end

        def validate
          self.superfluous_root_folders = self.root_folders - REQUIRED_ROOT_FOLDERS - OPTIONAL_ROOT_FOLDERS
          self.missing_root_folders = REQUIRED_ROOT_FOLDERS - self.root_folders

          self.superfluous_templates_folders = self.templates_folders - REQUIRED_TEMPLATES_FOLDERS
          self.missing_templates_folders = REQUIRED_TEMPLATES_FOLDERS - self.templates_folders
        end

        def valid?
          self.superfluous_root_folders.empty? && self.missing_root_folders.empty? &&
          self.superfluous_templates_folders.empty? && self.missing_templates_folders.empty?
        end
      end
    end
  end
end
