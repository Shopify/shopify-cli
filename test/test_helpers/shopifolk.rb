# frozen_string_literal: true
module TestHelpers
  module Shopifolk
    def teardown
      ShopifyCLI::Shopifolk.reset
      super
    end
  end
end
