# frozen_string_literal: true

module Extension
  module Loaders
    module Project
      def self.load(directory:)
        ExtensionProject.current
      end
    end
  end
end
