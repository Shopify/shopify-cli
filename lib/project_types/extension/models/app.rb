# frozen_string_literal: true

module Extension
  module Models
    class App
      include SmartProperties

      property! :api_key, accepts: String
      property :secret, accepts: String
      property :title, accepts: String
      property :business_name, accepts: String
    end
  end
end
