module Theme
  module UI
    class HostThemeProgressBar
      def initialize(syncer, git_dir)
        @syncer = syncer
        @git_dir = git_dir
      end

      def progress(method, **args)
        @syncer.lock_io!
        CLI::UI::Progress.progress do |bar|
          # Git.public_send(:clone, "https://github.com/Shopify/dawn.git", @git_dir) do |percent|
          #   bar.tick(set_percent: percent*.3)
          # end

          @syncer.public_send(method, **args) do |left, total|
            bar.tick(set_percent: 0.7 - (left.to_f / total) * 0.7)
          end

          bar.tick(set_percent: 1)
        end
        @syncer.unlock_io!
      end
    end
  end
end
