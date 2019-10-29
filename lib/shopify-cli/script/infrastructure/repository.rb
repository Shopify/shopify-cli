# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class Repository
        SOURCE_PATH = "#{Dir.pwd}/src"
        INSTALLATION_BASE_PATH = File.expand_path("../", __dir__)
      end
    end
  end
end
