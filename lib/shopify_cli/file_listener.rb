# frozen_string_literal: true
require "listen"
require "observer"

module ShopifyCLI
  class FileListener
    include Observable

    def initialize(root:, force_poll:, ignore_regex:)
      @root = root
      @force_poll = force_poll
      @ignore_regex = ignore_regex

      @listener = Listen.to(@root, force_polling: @force_poll, ignore: @ignore_regex) do |updated, added, removed|
        changed
        notify_observers(updated, added, removed)
      end
    end

    def start
      @listener.start
    end

    def stop
      @listener.stop
    end
  end
end
