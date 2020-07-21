# frozen_string_literal: true

module Script
  class ScriptProject < ShopifyCli::Project
    SUPPORTED_LANGUAGES = %w(ts)
    SOURCE_DIR = "src"

    attr_reader :extension_point_type, :script_name, :language

    def initialize(*args)
      super
      @extension_point_type = lookup_config('extension_point_type')
      @script_name = lookup_config('script_name')
      @language = 'ts'
      ShopifyCli::Core::Monorail.metadata = {
        "script_name" => @script_name,
        "extension_point_type" => @extension_point_type,
        "language" => @language,
      }
    end

    def file_name
      "script.#{language}"
    end

    def source_file
      "#{SOURCE_DIR}/#{file_name}"
    end

    def source_path
      "#{script_name}/#{source_file}"
    end

    private

    def lookup_config(key)
      raise Errors::InvalidContextError, key unless config.key?(key)
      config[key]
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
