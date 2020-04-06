module ShopifyCli
  module Core
    module Finalize
      class << self
        # Request changing the user's directory in their shell
        # We don't have direct access to this, so we must request it
        #
        # #### Parameters
        # `path` : the path to change
        #
        def request_cd(path)
          @cd = path
        end

        # Set an environment variable in a user's shell instance
        # We don't have direct access to this, so we must request it
        #
        # #### Parameters
        # `key` : the key of the environment variable
        # `value` : the value of the environment variable
        #
        def setenv(key, value)
          @setenv ||= {}
          @setenv[key] = value
        end

        # Reload shopify.sh or shopify.fish
        #
        def reload_shopify_from(path)
          @reload = path
        end

        # Finalize all requests to change a user's shell environment
        #
        def deliver!
          message = []

          message << "cd:#{@cd}" if @cd
          message << "reload_shopify_cli_from:#{@reload}" if @reload
          (@setenv || {}).each do |k, v|
            message << "setenv:#{k}=#{v}"
          end

          return if message.empty?
          begin
            finalizer_pipe.puts(message.join("\n"))
          rescue Errno::EBADF, IOError
            $stderr.puts "Not running with shell integration. Finalizers: #{message.join("\n")}"
          ensure
            clear
          end
        end

        private

        def clear
          @cd = @setenv = @reload = nil
        end

        def finalizer_pipe
          IO.new(finalizer_fd)
        rescue ArgumentError => e
          # Looks like fd 9 is in use, try to find it
          ObjectSpace.each_object(IO) do |io|
            next if io.closed? || io.fileno != finalizer_fd
            raise ShopifyCli::Bug, "File descriptor #{io.fileno}, of type #{io.stat.ftype}, is not available."
          end
          raise e
        end

        def finalizer_fd
          9
        end
      end
    end
  end
end
