require "open3"

module Utilities
  module Docker
    Error = Class.new(StandardError)

    class << self
      def rm(container_id:)
        build_image_if_needed
        _, stderr, stat = Open3.capture3(
          "docker", "rm", "-f", container_id
        )
        raise Error, stderr unless stat.success?
      end

      def capture(*args, container_id:, cwd: nil, env: {})
        command = ["docker", "exec"]
        unless cwd.nil?
          command += ["-w", cwd]
        end
        env.each do |env_name, env_value|
          command += ["--env", "#{env_name}=#{env_value}"]
        end
        command << container_id
        command += args

        out, err, stat = Open3.capture3(*command)
        raise Error, err unless stat.success?
        out
      end

      def exec(*args, container_id:, cwd: nil, env: {})
        command = ["docker", "exec"]
        unless cwd.nil?
          command += ["-w", cwd]
        end
        env.each do |env_name, env_value|
          command += ["--env", "#{env_name}=#{env_value}"]
        end
        command << container_id
        command += args

        out, stat = Open3.capture2e(*command)
        raise Error, out unless stat.success?
      end

      def run(*args, container_id:)
        build_image_if_needed
        _, stderr, stat = Open3.capture3(
          "docker", "run",
          "-t", "-d",
          "--name", container_id,
          "--volume", "#{Shellwords.escape(root_dir)}:/usr/src/app",
          image_tag,
          *args
        )
        raise Error, stderr unless stat.success?
      end

      def run_and_rm_container(*args)
        build_image_if_needed
        system(
          "docker", "run",
          "-t", "--rm",
          "--volume", "#{Shellwords.escape(root_dir)}:/usr/src/app",
          image_tag,
          *args
        ) || abort
      end

      private

      def root_dir
        File.expand_path("..", __dir__)
      end

      def build_image_if_needed
        unless image_exists?(image_tag)
          _, err, stat = Open3.capture3(
            "docker", "build", root_dir, "-t", image_tag
          )
          raise Error, err unless stat.success?
        end
      end

      def image_tag
        gemfile_lock_path = File.expand_path("./Gemfile.lock", root_dir)
        dockerfile_path = File.expand_path("./Dockerfile", root_dir)
        fingerprintable_strings = [
          File.read(gemfile_lock_path),
          File.read(dockerfile_path),
        ]
        image_sha = Digest::SHA256.hexdigest(fingerprintable_strings.join("-"))
        "shopify-cli-#{image_sha}"
      end

      def image_exists?(tag)
        _, stat = Open3.capture2e(
          "docker", "inspect",
          "--type=image",
          tag
        )
        stat.success?
      end
    end
  end
end
