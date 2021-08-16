# frozen_string_literal: true

module Extension
  module Models
    class Product
      include SmartProperties

      property :variant_id, accepts: Integer, converts: :to_i
      property :quantity, accepts: Integer, default: 1
    end
  end
end
