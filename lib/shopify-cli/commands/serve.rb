# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Serve < ShopifyCli::Command
      include ShopifyCli::Helpers::OS

      prerequisite_task :tunnel

      def call(*)
        if mac?
          @ctx.puts("{{green:! tip}} Press Control-T to open this project in your browser")
          on_siginfo do
            @ctx.project.app_type.open(@ctx)
          end
        end
        @ctx.system(@ctx.project.app_type.serve_command(@ctx))
      end

      def self.help
        <<~HELP
          Start a local development server for your project, as well as a public ngrok tunnel to your localhost.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} serve}}
        HELP
      end

      def on_siginfo
        fork do
          begin
            r, w = IO.pipe
            @signal = false
            trap('SIGINFO') do
              @signal = true
              w.write(0)
            end
            while r.read(1)
              next unless @signal
              @signal = false
              yield
            end
          rescue Interrupt
            exit(0)
          end
        end
      end
    end
  end
end
