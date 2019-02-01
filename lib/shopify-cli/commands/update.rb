require 'shopify-cli'

module ShopifyCli
  module Commands
    class Update < ShopifyCli::Command
      def self.help
        "Update shopify-cli."
      end

      def call(_args, _name)
        if File.exist?(File.expand_path('.git/HEAD.lock', ShopifyCli::ROOT))
          err("failed!")
          err("It looks like another git operation is in progress on {{blue:#{ShopifyCli::ROOT}}}.")
          err("Try running {{green:dev update}}.")
          err("If that fails, you must run {{green: rm #{ShopifyCli::ROOT}/.git/HEAD.lock}} to continue.")
          raise(ShopifyCli::AbortSilent)
        end

        if File.exist?(File.expand_path(".git/refs/heads/master.lock", ShopifyCli::ROOT))
          err("failed!")
          err("It looks like another git operation is in progress on {{blue:#{ShopifyCli::ROOT}}}.")
          err("Try running {{green:dev update}}.")
          err("If that fails, you must run {{green: rm #{ShopifyCli::ROOT}/.git/refs/heads/master.lock}} to continue.")
          raise(ShopifyCli::AbortSilent)
        end

        _, stat = CLI::Kit::System.capture2e('git', '-C', ShopifyCli::ROOT, 'fetch', 'origin', 'master')
        unless stat.success?
          raise(ShopifyCli::Abort, 'failed!')
        end

        commands = [
          ['reset', '.'],
          ['checkout', '.'],
          ['checkout', '-f', '-B', 'master'],
          ['reset', '--hard', 'FETCH_HEAD'],
        ]
        spin_group = CLI::UI::SpinGroup.new
        spin_group.add('Updating shopify-cli') do |spinner|
          commands.each do |args|
            _, stat = CLI::Kit::System.capture2e('git', '-C', ShopifyCli::ROOT, *args)
            raise(ShopifyCli::Abort, "command failed: #{args.join(' ')}") unless stat.success?
          end
          spinner.update_title('Updated shopify-cli')
        end
        spin_group.wait
      end

      def err(msg, newline: true)
        method = newline ? :puts : :print
        STDERR.send(method, CLI::UI.fmt("{{bold:{{red:#{msg}}}}}"))
      end
    end
  end
end

