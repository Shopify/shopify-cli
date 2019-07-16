require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Clone < ShopifyCli::Task
      def call(*args)
        repository = args.shift
        dest = args.shift
        CLI::UI::Frame.open("Cloning into #{dest}...") do
          git_progress('clone', '--single-branch', repository, dest)
        end
        puts CLI::UI.fmt("{{v}} Cloned app in #{dest}")
      end

      def git_progress(*git_command)
        CLI::UI::Progress.progress do |bar|
          msg = []
          success = CLI::Kit::System.system('git', *git_command, '--progress') do |_out, err|
            if err.strip.start_with?('Receiving objects:')
              percent = (err.match(/Receiving objects:\s+(\d+)/)[1].to_f / 100).round(2)
              bar.tick(set_percent: percent)
              next
            end
            msg << err
          end.success?
          unless success
            raise CLI::UI.fmt("{{red:#{msg.join("\n")}}}")
          end
          bar.tick(set_percent: 1.0)
          true
        end
      end
    end
  end
end
