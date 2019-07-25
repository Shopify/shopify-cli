module ShopifyCli
  class Context
    module Output
      def print_task(text)
        puts CLI::UI.fmt("{{yellow:*}} #{text}")
      end

      def puts(*args)
        Kernel.puts(CLI::UI.fmt(*args))
      end

      def done(string)
        puts("{{v}} #{string}")
      end

      def debug(string)
        puts("{{red:DEBUG}} #{string}") if getenv('DEBUG')
      end
    end
  end
end
