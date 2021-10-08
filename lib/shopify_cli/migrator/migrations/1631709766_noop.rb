# frozen_string_literal: true

module ShopifyCLI
  module Migrator
    module Migrations
      class Noop
        def self.run
          # This is a noop migration to be used as a reference
        end
      end
    end
  end
end
