require "open3"
require "securerandom"

module Utilities
  module Docker
    autoload :Container, "docker/container"

    Error = Class.new(StandardError)

    class << self
      def create_container(env: {})
        id = SecureRandom.hex
        cwd = "/tmp/#{SecureRandom.hex}"

        build_image_if_needed

        _, stderr, stat = Open3.capture3(
          "docker", "run",
          "-t", "-d",
          "--name", id,
          "--volume", "#{Shellwords.escape(root_dir)}:/usr/src/app",
          image_tag,
          "tail", "-f", "/dev/null"
        )
        raise Error, stderr unless stat.success?

        _, stderr, stat = Open3.capture3(
          "docker", "exec",
          id,
          "mkdir", "-p", cwd
        )
        raise Error, stderr unless stat.success?

        Container.new(
          id: id,
          cwd: cwd,
          env: env
        )
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
          puts "Rebuilding the Docker image..."
          _, err, stat = Open3.capture3(
            "docker", "build", "-t", image_tag, "-f", File.join(root_dir, "Tests.dockerfile"), root_dir
          )
          raise Error, err unless stat.success?
        end
      end

      def image_tag
        gemfile_lock_path = File.expand_path("./Gemfile.lock", root_dir)
        dockerfile_path = File.expand_path("./Tests.dockerfile", root_dir)
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
