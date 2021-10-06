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

      def run(*args, container_id:)
        build_image_if_needed
        _, stderr, stat = Open3.capture3(
          "docker", "run",
          "-t",
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
          system("docker", "build", root_dir, "-t", image_tag) || abort
        end
      end

      def image_tag
        gemfile_lock_path = File.expand_path("./Gemfile.lock", root_dir)
        image_sha = Digest::SHA256.hexdigest(File.read(gemfile_lock_path))
        "shopify-cli-#{image_sha}"
      end

      def image_exists?(tag)
        _, stat = Open3.capture2(
          "docker", "inspect",
          "--type=image",
          tag
        )
        stat.success?
      end
    end
  end
end
