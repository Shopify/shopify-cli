require 'fileutils'

module ShopifyCli
  class Context
    module System
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
        @uname ||= capture2("uname -#{flag}")[0].strip
      end

      def spawn(*args, **kwargs)
        Kernel.spawn(@env, *args, **kwargs)
      end

      def system(*args, **kwargs)
        CLI::Kit::System.system(*args, env: @env, **kwargs)
      end

      def capture2(*args, **kwargs)
        CLI::Kit::System.capture2(*args, env: @env, **kwargs)
      end

      def capture2e(*args, **kwargs)
        CLI::Kit::System.capture2e(*args, env: @env, **kwargs)
      end

      def capture3(*args, **kwargs)
        CLI::Kit::System.capture3(*args, env: @env, **kwargs)
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
