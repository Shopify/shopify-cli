require 'shopify_cli'

module ShopifyCli
  module Tasks
    class JsDeps < ShopifyCli::Task
      INSTALL_COMMANDS = {
        yarn: %w(yarn),
        npm: %w(npm install --no-optional),
      }.freeze

      def call(*args)
        @dir = args.shift || Dir.pwd

        CLI::UI::Frame.open("Installing dependencies with #{installer}...") do
          install_progress
        end
      end

      def installer
        @installer = yarn? ? :yarn : :npm
      end

      def yarn?
        return false unless File.exist?(File.join(@dir, 'yarn.lock'))
        CLI::Kit::System.system('which', 'yarn').success?
      end

      def install_progress
        success = CLI::Kit::System.system(*INSTALL_COMMANDS[installer], chdir: @dir) do |_out, err|
          err.lines.each do |e|
            puts e
          end
        end.success?
        return false unless success
        true
      end
    end
  end
end
