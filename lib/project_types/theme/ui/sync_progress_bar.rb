module Theme
  module UI
    class SyncProgressBar
      def initialize(syncer)
        @syncer = syncer
      end

      def progress(method, **args)
        @syncer.delay_errors!
        CLI::UI::Progress.progress do |bar|
          @syncer.public_send(method, **args) do |left, total|
            bar.tick(set_percent: 1 - left.to_f / total)
          end
          bar.tick(set_percent: 1)
        end
        @syncer.report_errors!
      end
    end
  end
end
