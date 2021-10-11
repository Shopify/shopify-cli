require "open3"

module Utilities
  module Docker
    class Container
      SHOPIFY_BIN_PATH = "/usr/src/app/bin/shopify"

      Error = Class.new(StandardError)

      attr_reader :id, :env, :cwd, :xdg_config_home, :xdg_cache_home

      def initialize(id:, env:, cwd:)
        @id = id
        @cwd = cwd
        @xdg_config_home = File.join(cwd, ".config")
        @xdg_cache_home = File.join(cwd, ".cache")
        @env = env.merge({
          "XDG_CONFIG_HOME" => @xdg_config_home,
          "XDG_CACHE_HOME" => @xdg_cache_home,
        })
      end

      def remove
        _, stderr, stat = Open3.capture3(
          "docker", "rm", "-f", @id
        )
        raise Error, stderr unless stat.success?
      end

      def capture_shopify(*args)
        capture(*([SHOPIFY_BIN_PATH] + args))
      end

      def capture(*args)
        command = ["docker", "exec"]
        unless @cwd.nil?
          command += ["-w", @cwd]
        end
        @env.each do |env_name, env_value|
          command += ["--env", "#{env_name}=#{env_value}"]
        end
        command << @id
        command += args

        out, err, stat = Open3.capture3(*command)
        raise Error, err unless stat.success?
        out
      end

      def exec_shopify(*args)
        exec(*([SHOPIFY_BIN_PATH] + args))
      end

      def exec(*args)
        command = ["docker", "exec"]
        unless @cwd.nil?
          command += ["-w", @cwd]
        end
        @env.each do |env_name, env_value|
          command += ["--env", "#{env_name}=#{env_value}"]
        end
        command << @id
        command += args

        out, stat = Open3.capture2e(*command)
        raise Error, out unless stat.success?
      end
    end
  end
end
