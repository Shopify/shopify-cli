# frozen_string_literal: true

module Extension
  module Models
    class Registration
      include SmartProperties

      property! :id, accepts: Integer
      property! :type, accepts: String
      property! :title, accepts: String
    end
  end
end
