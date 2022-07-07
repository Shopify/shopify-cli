# frozen_string_literal: true
require "shopify_cli/file_system_listener"
require "forwardable"

module ShopifyCLI
  module Theme
    module DevServer
      # Watches for file changes and publish events to the theme
      class AppExtensionWatcher
        extend Forwardable

        def_delegators :@listener, :add_observer, :changed, :notify_observers

        def initialize(ctx, extension:, poll: false)
          @ctx = ctx
          @listener = FileSystemListener.new(root: extension.root.to_s, force_poll: poll, ignore_regex: nil)
          add_observer(self, :testing)
        end

        def testing(modified, added, removed)
          puts "#{modified}, #{added}, #{removed}"
        end

        def start
          @listener.start
        end

        def stop
          @listener.stop
        end
      end
    end
  end
end
