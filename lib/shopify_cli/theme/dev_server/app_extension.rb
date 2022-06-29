# TODO create new class to pass as an app
# with a call method like HotReload

# frozen_string_literal: true

require_relative "hot_reload/remote_file_reloader"
require_relative "hot_reload/sections_index"

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtension
        def initialize(ctx)
          @ctx = ctx
        end

        def call(env)
          puts('---hello')
        end

        def close
          @streams.close
        end

      end
    end
  end
end
