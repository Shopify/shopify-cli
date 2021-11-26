module Theme
  module UI
    class SyncProgressBar
      def initialize(syncer)
        @syncer = syncer
      end

      def progress(method, **args)
        @syncer.lock_io!
        CLI::UI::Progress.progress do |bar|
          @syncer.public_send(method, **args) do |left, total|
            bar.tick(set_percent: 1 - left.to_f / total)
          end
          bar.tick(set_percent: 1)
        end
        @syncer.unlock_io!
      end
    end
  end
end
