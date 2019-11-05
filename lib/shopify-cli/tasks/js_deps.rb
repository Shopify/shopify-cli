require 'shopify_cli'

module ShopifyCli
  module Tasks
    class JsDeps < ShopifyCli::Task
      include SmartProperties

      INSTALL_COMMANDS = {
        yarn: %w(yarn install --silent),
        npm: %w(npm install --no-audit --no-optional --silent),
      }.freeze

      def call(ctx)
        @ctx = ctx
        @dir = ctx.root

        CLI::UI::Frame.open("Installing dependencies with #{installer}...") do
          send(installer)
        end
        puts CLI::UI.fmt("{{v}} Dependencies installed")
      end

      def installer
        @installer = yarn? ? :yarn : :npm
      end

      def yarn?
        return false unless File.exist?(File.join(@dir, 'yarn.lock'))
        CLI::Kit::System.system('which', 'yarn').success?
      end

      def yarn
        success = CLI::Kit::System.system(*INSTALL_COMMANDS[installer], chdir: @dir) do |out, err|
          puts out
          err.lines.each do |e|
            puts e
          end
        end.success?
        return false unless success
        true
      end

      def npm
        package_json = File.join(@dir, 'package.json')
        pkg = begin
                JSON.parse(File.read(package_json))
              rescue Errno::ENOENT, Errno::ENOTDIR
                raise(ShopifyCli::Abort, "expected to have a file at: #{package_json}")
              end

        deps = %w(dependencies devDependencies).map do |key|
          pkg.fetch(key, []).keys
        end.flatten
        @ctx.puts("Installing #{deps.size} dependencies")
        CLI::Kit::System.system(*INSTALL_COMMANDS[installer], chdir: @dir)
      rescue JSON::ParserError
        ctx.puts(
          "{{info:#{File.read(File.join(path, 'package.json'))}}} was not valid JSON. Fix this then try again",
          error: true
        )
        raise ShopifyCli::AbortSilent
      end
    end
  end
end
