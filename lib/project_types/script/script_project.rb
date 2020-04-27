# frozen_string_literal: true

module Script
  class ScriptProject < ShopifyCli::Project
    SUPPORTED_LANGUAGES = %w(ts)

    attr_reader :extension_point_type, :script_name, :language

    def initialize(dir)
      super(dir)
      @extension_point_type = lookup_config('extension_point_type')
      @script_name = lookup_config('script_name')
      @language = 'ts'
    end

    private

    def lookup_config(key)
      raise InvalidContextError, key unless config.key?(key)
      config[key]
    end

    class << self
      def create(dir)
        raise ScriptProjectAlreadyExistsError, dir if Dir.exist?(dir)

        FileUtils.mkdir_p(dir)
        Dir.chdir(dir)
      end
    end
  end
end
