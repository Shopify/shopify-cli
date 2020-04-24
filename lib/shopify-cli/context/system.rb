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
        host = uname
        return :mac if /darwin/.match(host)
        return :linux if /linux/.match(host)
      end

      def mac?
        os == :mac
      end

      def linux?
        os == :linux
      end

      def system?
        ShopifyCli::INSTALL_DIR == ShopifyCli::ROOT
      end

      def development?
        !system? && !testing?
      end

      def testing?
        ci? || ENV['TEST']
      end

      def ci?
        ENV['CI']
      end

      def uname
        @uname ||= RbConfig::CONFIG["host"]
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
