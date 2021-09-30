require "open3"

module Utilities
  module Docker
    Error = Class.new(StandardError)

    class << self
      def create_and_start_disposable_container
        build_image_if_needed
        container_id, create_err, create_stat = Open3.capture3("docker", "create", "-t", "-i", image_tag)
        raise Error, create_err unless create_stat.success?
        _, start_err, start_stat = Open3.capture3("docker", "start", "-i", container_id)
        raise Error, start_err unless start_stat.success?
        container_id
      end

      def run(*args, container_id:)
        system(
          "docker", "run",
          "-t",
          "--volume", "#{Shellwords.escape(root_dir)}:/usr/src/app",
          container_id,
          *args
        ) || abort
      end

      def delete_container(id)
        _, err, stat = Open3.capture3("docker", "container", "rm", "-f", id)
        raise Error, err unless stat.success?
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
        dockerfile_path = File.expand_path("./Dockerfile", root_dir)
        image_sha = Digest::SHA256.hexdigest(File.read(dockerfile_path))
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
