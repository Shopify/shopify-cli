require 'fileutils'

module ShopifyCli
  class Context
    module System
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
    end
  end
end
