# frozen_string_literal: true

module Script
  class ScriptProject < ShopifyCli::Project
    SUPPORTED_LANGUAGES = %w(ts)
    SOURCE_DIR = "src"

    attr_reader :extension_point_type, :script_name, :language

    def initialize(dir)
      super(dir)
      @extension_point_type = lookup_config('extension_point_type')
      @script_name = lookup_config('script_name')
      @language = 'ts'
    end

    def source_file
      "#{SOURCE_DIR}/#{file_name}"
    end

    def file_name
      "script.#{language}"
    end

    private

    def lookup_config(key)
      raise Errors::InvalidContextError, key unless config.key?(key)
      config[key]
    end

    class << self
      def create(dir)
        raise Errors::ScriptProjectAlreadyExistsError, dir if Dir.exist?(dir)

        FileUtils.mkdir_p(dir)
        Dir.chdir(dir)
      end

      def cleanup(ctx:, script_name:, root_dir:)
        Dir.chdir(root_dir)
        ctx.rm_r("#{root_dir}/#{script_name}") if Dir.exist?("#{root_dir}/#{script_name}")
      end
    end
  end
end
