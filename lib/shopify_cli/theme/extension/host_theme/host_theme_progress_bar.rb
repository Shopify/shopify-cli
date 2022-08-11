# frozen_string_literal: true
module ShopifyCLI
  module Theme
    module Extension
      class HostTheme < DevelopmentTheme
        class HostThemeProgressBar
          GIT_CLONE_PROGRESS_SHARE = 0.2
          SYNC_PROGRESS_SHARE = 0.8

          def initialize(syncer, dir)
            # TODO: fix sig
            @syncer = syncer
            @dir = dir
          end

          def progress(method, **args)
            @syncer.lock_io!
            ::CLI::UI::Progress.progress do |bar|
              Git.public_send(:clone, "https://github.com/Shopify/dawn.git", @dir) do |percent|
                bar.tick(set_percent: percent * GIT_CLONE_PROGRESS_SHARE)
              end

              @syncer.public_send(method, **args) do |left, total|
                bar.tick(set_percent: (1 - left.to_f / total) * SYNC_PROGRESS_SHARE + GIT_CLONE_PROGRESS_SHARE)
              end

              bar.tick(set_percent: 1)
            end
            @syncer.unlock_io!
          end
        end
      end
    end
  end
end
