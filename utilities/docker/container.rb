require "open3"
require "colorize"

module Utilities
  module Docker
    class Container
      SHOPIFY_PATH = "/usr/src/app"
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

      def capture(*args, relative_dir: nil)
        command = ["docker", "exec"]
        cwd = if relative_dir.nil?
          @cwd
        else
          File.join(@cwd, relative_dir)
        end
        command += ["-w", cwd]
        @env.each do |env_name, env_value|
          command += ["--env", "#{env_name}=#{env_value}"]
        end
        command << @id
        command += args

        out, err, stat = Open3.capture3(*command)
        raise Error, err unless stat.success?
        out
      end

      def exec_shopify(*args, relative_dir: nil)
        exec(*([SHOPIFY_BIN_PATH] + args), relative_dir: relative_dir)
      end

      def exec(*args, relative_dir: nil)
        if ARGV.include?("--verbose")
          running_prefix = "Running command: #{args.join(" ")}"
          STDOUT.puts(running_prefix.colorize(:yellow).bold)
        end
        command = ["docker", "exec"]
        cwd = if relative_dir.nil?
          @cwd
        else
          File.join(@cwd, relative_dir)
        end
        command += ["-w", cwd]
        @env.each do |env_name, env_value|
          command += ["--env", "#{env_name}=#{env_value}"]
        end
        command << @id
        command += args

        docker_prefix = "Docker (#{args.first}):"

        if ARGV.include?("--verbose")
          stat = Open3.popen3(*command) do |stdin, stdout, stderr, wait_thread|
            Thread.new do
              stdout.each { |l| STDOUT.puts("#{docker_prefix.colorize(:cyan).bold} #{l}") } unless stdout&.nil?
            end
            Thread.new do
              stderr.each { |l| STDERR.puts("#{docker_prefix.colorize(:red).bold} #{l}") } unless stderr&.nil?
            end
            stdin.close

            status = wait_thread.value

            stdout.close
            stderr.close

            status
          end
          raise StandardError, "The command #{args.first} failed" unless stat.success?
        else
          out, stat = Open3.capture2e(*command)
          raise Error, out unless stat.success?
        end
      end
    end
  end
end
