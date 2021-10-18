module ShopifyCLI
  class Command
    class AppSubCommand < SubCommand
      def detect_app(directory: Dir.pwd)
        AppTypeDetector.detect(project_directory: directory)
      rescue ShopifyCLI::AppTypeDetector::TypeNotFoundError
        raise ShopifyCLI::Abort, @ctx.message("core.app.type_not_found", directory)
      end

      class << self
        def call_help(*)
          output = help
          if respond_to?(:extended_help)
            output += "\n"
            output += extended_help
          end
          @ctx.puts(output)
        end
      end
    end
  end
end
