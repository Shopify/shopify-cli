# frozen_string_literal: true

module TestHelpers
  module FakeDB
    def stubs_cli_db(key, value = nil)
      ShopifyCLI::DB.stubs(:get).with(key).returns(value)
      ShopifyCLI::DB.stubs(:exists?).with(key).returns(true)
    end
  end
end
