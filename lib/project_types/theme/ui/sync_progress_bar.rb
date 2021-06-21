module Theme
  module UI
    class SyncProgressBar
      def initialize(uploader)
        @uploader = uploader
      end

      def progress(method, **args)
        @uploader.delay_errors!
        CLI::UI::Progress.progress do |bar|
          @uploader.public_send(method, **args) do |left, total|
            bar.tick(set_percent: 1 - left.to_f / total)
          end
          bar.tick(set_percent: 1)
        end
        @uploader.report_errors!
      end
    end
  end
end
