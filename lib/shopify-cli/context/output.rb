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

      def page(output)
        if output.split("\n").size > CLI::UI::Terminal.height
          IO.popen(getenv('PAGER') || 'less', "w") do |pipe|
            pipe.puts CLI::UI.fmt(output)
          end
        else
          puts(CLI::UI.fmt(output))
        end
      end
    end
  end
end
