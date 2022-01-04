# typed: ignore
# frozen_string_literal: true
module TestHelpers
  class FakeProject < ShopifyCLI::Project
    include SmartProperties
    property :directory
    property :config
  end
end
