# frozen_string_literal: true

require "pathname"

TSCONFIG_FILE = "tsconfig.json"
TSCONFIG_EXTENDS_PATH = "/node_modules/assemblys"

module Script
  module Layers
    module Infrastructure
      class AssemblyScriptTsConfig
        attr_reader :config

        def initialize(dir_to_write_in:)
          @dir_to_write_in = dir_to_write_in
          @config = {}
        end

        def with_extends_assemblyscript_config(relative_path_to_node_modules:)
          relative_path = Pathname.new(relative_path_to_node_modules).relative_path_from(@dir_to_write_in)
          @config[:extends] = "#{relative_path}/node_modules/assemblyscript/std/assembly.json"
          self
        end

        def with_module_resolution_paths(paths:)
          @config[:compilerOptions] = {
            baseUrl: ".",
            paths: paths,
          }
          self
        end

        def write
          File.write("#{@dir_to_write_in}/#{TSCONFIG_FILE}", JSON.pretty_generate(@config))
        end
      end
    end
  end
end
