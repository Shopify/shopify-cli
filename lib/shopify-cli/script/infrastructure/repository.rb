# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class Repository
        INSTALLATION_BASE_PATH = File.expand_path("../", __dir__)
        FOLDER_PATH_TEMPLATE = "#{Dir.pwd}/%{script_name}"
      end
    end
  end
end
