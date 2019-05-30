# frozen_string_literal: true
module TestHelpers
  class FakeProject < ShopifyCli::Project
    include SmartProperties
    property :directory
    property :config
  end
end
