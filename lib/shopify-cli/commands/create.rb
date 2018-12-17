require 'shopify-cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::Command
      def call(args, _name)
        @name = args.shift
        return puts CLI::UI.fmt(self.class.help) unless @name

        app_type = CLI::UI::Prompt.ask('What type of app would you like to create?') do |handler|
          handler.option('node embedded app') { |selection| 'embedded_app' }
          handler.option('ruby embedded app') { |selection| return false }
        end

        return puts "not yet implemented" unless app_type

        method(app_type).call
      end

      def embedded_app
        CLI::UI::Frame.open('Cloning embeddedapp...') do
          git_progress('clone', '--single-branch', 'git@github.com:shopify/webgen-embeddedapp.git', @name)
        end
        api_key = CLI::UI.ask('What is your Shopify API Key')
        api_secret = CLI::UI.ask('What is your Shopify API Secret')
        File.write(File.join(@name, '.env'),
          "SHOPIFY_API_KEY=#{api_key}\nSHOPIFY_API_SECRET_KEY=#{api_secret}")

        CLI::UI::Frame.open('Installing dependencies...') do
          yarn
        end
        puts CLI::UI.fmt(post_clone)
        ShopifyCli::Finalize.request_cd(@name)
      end

      def post_clone
        "Run {{command:shopify server}} to start the app server"
      end

      def self.help
        "Bootstrap an app.\nUsage: {{command:#{ShopifyCli::TOOL_NAME} create <apptype> <appname>}}"
      end

      def git_progress(*git_command)
        CLI::UI::Progress.progress do |bar|
          success = CLI::Kit::System.system('git', *git_command, '--progress') do |_out, err|
            next unless err.strip.start_with?('Receiving objects:')
            percent = (err.match(/Receiving objects:\s+(\d+)/)[1].to_f / 100).round(2)
            bar.tick(set_percent: percent)
          end.success?
          return false unless success
          bar.tick(set_percent: 1.0)
          true
        end
      end

      def yarn
        CLI::UI::Progress.progress do |bar|
          success = CLI::Kit::System.system('npm install', chdir: @name) do |_out, err|
            match = err.match(/(\d+)\/(\d+)/)
            next unless match
            percent = (match[1] / match[2] * 100).round(2)
            bar.tick(set_percent: percent)
          end.success?
          return false unless success
          bar.tick(set_percent: 1.0)
          true
        end
      end
    end
  end
end
