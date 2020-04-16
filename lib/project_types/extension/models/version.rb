# frozen_string_literal: true

module Extension
  module Models
    class Version
      include SmartProperties

      property! :registration_id, accepts: Integer
      property :context, accepts: String
    end
  end
end
