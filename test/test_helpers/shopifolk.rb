# frozen_string_literal: true
module TestHelpers
  module Shopifolk
    def teardown
      ShopifyCli::Shopifolk.reset
      super
    end
  end
end
