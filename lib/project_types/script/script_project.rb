# frozen_string_literal: true

module Script
  class ScriptProject < ShopifyCli::Project
    attr_reader :extension_point_type, :script_name, :language, :description, :configuration_ui_yaml

    def initialize(*args)
      super
      @extension_point_type = lookup_config!("extension_point_type")
      raise Errors::DeprecatedEPError, @extension_point_type if deprecated?(@extension_point_type)
      @script_name = lookup_config!("script_name")
      @description = lookup_config("description")
      @configuration_ui_yaml = lookup_configuration_ui_yaml
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

    def lookup_configuration_ui_yaml
      filename = lookup_config("configuration_ui_file")
      return nil unless filename

      path = File.join(directory, filename)
      raise Errors::MissingSpecifiedConfigUiDefinitionError, filename unless File.exist?(path)

      contents = File.read(path)
      raise Errors::InvalidConfigUiDefinitionError, filename unless valid_configuration_ui_yaml?(contents)

      contents
    end

    def lookup_language
      lang = lookup_config("language")&.downcase || Layers::Domain::ExtensionPointAssemblyScriptSDK.language
      if Layers::Application::ExtensionPoints.supported_language?(type: extension_point_type, language: lang)
        lang
      else
        raise Errors::InvalidLanguageError.new(lang, extension_point_type)
      end
    end

    def valid_configuration_ui_yaml?(raw_yaml)
      require "yaml" # takes 20ms, so deferred as late as possible.
      YAML.safe_load(raw_yaml)
      true
    rescue Psych::SyntaxError
      false
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
