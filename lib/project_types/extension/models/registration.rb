# frozen_string_literal: true

module Extension
  module Models
    class Registration
      MAX_TITLE_LENGTH = 50
      include SmartProperties

      property! :id, accepts: Integer
      property! :type, accepts: String
      property! :title, accepts: String

      def self.valid_title?(title)
        !title.nil? && !title.strip.empty? && title.length <= MAX_TITLE_LENGTH
      end
    end
  end
end
