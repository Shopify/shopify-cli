# frozen_string_literal: true

module Script
  class ScriptProject < ShopifyCli::Project
    attr_reader :extension_point_type, :script_name, :language

    def initialize(*args)
      super
      @extension_point_type = lookup_config!('extension_point_type')
      raise Errors::DeprecatedEPError, @extension_point_type if deprecated?(@extension_point_type)
      @script_name = lookup_config!('script_name')
      @language = lookup_language
      ShopifyCli::Core::Monorail.metadata = {
        "script_name" => @script_name,
        "extension_point_type" => @extension_point_type,
        "language" => @language,
      }
    end

    def api_key
      env[:api_key]
    end

    private

    def deprecated?(ep)
      Script::Layers::Application::ExtensionPoints.deprecated_types.include?(ep)
    end

    def lookup_config(key)
      return nil unless config.key?(key)
      config[key]
    end

    def lookup_config!(key)
      raise Errors::InvalidContextError, key unless config.key?(key)
      config[key]
    end

    def lookup_language
      lang = lookup_config('language')&.downcase || Layers::Domain::ExtensionPointAssemblyScriptSDK.language
      if Layers::Application::ExtensionPoints.supported_language?(type: extension_point_type, language: lang)
        lang
      else
        raise Errors::InvalidLanguageError.new(lang, extension_point_type)
      end
    end

    class << self
      def create(ctx, dir)
        raise Errors::ScriptProjectAlreadyExistsError, dir if ctx.dir_exist?(dir)
        ctx.mkdir_p(dir)
        ctx.chdir(dir)
      end

      def cleanup(ctx:, script_name:, root_dir:)
        ctx.chdir(root_dir)
        ctx.rm_r("#{root_dir}/#{script_name}") if ctx.dir_exist?("#{root_dir}/#{script_name}")
      end
    end
  end
end
