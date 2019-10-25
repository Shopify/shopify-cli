module ShopifyCli
  module Helpers
    module OS
      OPEN_COMMANDS = {
        'open' => 'open',
        'xdg-open' => 'xdg-open',
        'rundll32' => 'rundll32 url.dll,FileProtocolHandler',
        'python' => 'python -m webbrowser',
      }

      def os
        return :mac if mac?
        return :linux if linux?
      end

      def mac?
        /Darwin/.match(uname)
      end

      def linux?
        /Linux/.match(uname)
      end

      def uname(flag: 'a')
        @uname ||= CLI::Kit::System.capture2("uname -#{flag}")[0].strip
      end

      def open_url!(ctx, uri)
        return ctx.system("open '#{uri}'") if mac?
        help = <<~OPEN
          Please open {{green:#{uri}}} in your browser
        OPEN
        ctx.puts(help)
      end
    end
  end
end
