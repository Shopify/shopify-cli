# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Context
    autoload :FileSystem, 'shopify-cli/context/file_system'
    autoload :Output, 'shopify-cli/context/output'
    autoload :System, 'shopify-cli/context/system'

    include SmartProperties
    include FileSystem
    include Output
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

    def app_metadata
      @app_metadata ||= {}
    end

    def app_metadata=(hash)
      @app_metadata = app_metadata.merge(hash)
    end

    def open_url!(uri)
      return system("open '#{uri}'") if mac?
      help = <<~OPEN
        Please open {{green:#{uri}}} in your browser
      OPEN
      puts(help)
    end
  end
end
