# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Context
    autoload :FileSystem, 'shopify-cli/context/file_system'
    autoload :System, 'shopify-cli/context/system'

    include SmartProperties
    include FileSystem
    include System

    property :root, default: lambda { Dir.pwd }, converts: :to_s
    property :env, default: lambda { ($original_env || ENV).clone }

    def getenv(name)
      v = @env[name]
      v == '' ? nil : v
    end

    def setenv(key, value)
      @env[key] = value
    end

    def print_task(text)
      puts CLI::UI.fmt("{{yellow:*}} #{text}")
    end

    def puts(*args)
      Kernel.puts(CLI::UI.fmt(*args))
    end

    def debug(msg)
      if @env['DEBUG']
        puts("{{yellow:DEBUG}} #{msg}")
      end
    end

    def app_metadata
      @app_metadata ||= {}
    end

    def app_metadata=(hash)
      @app_metadata = app_metadata.merge(hash)
    end
  end
end
