# frozen_string_literal: true

module Extension
  module Features
    class ArgoDependencies
      def self.node_installed(min_major:, min_minor: nil)
        -> (context) do
          out, status = CLI::Kit::System.capture2("node", "-v")
          context.abort(context.message("features.argo.dependencies.node.node_not_installed")) unless status.success?

          min_version = "v" + min_major .to_s + "." + (min_minor.nil? ? "x" : min_minor.to_s) + ".x"
          version = out.strip
          parsed_version = version.match(/v(?<major>\d+).(?<minor>\d+).(?<patch>\d+)/)

          unless min_major.nil? || parsed_version[:major].to_i >= min_major
            context.abort(context.message("features.argo.dependencies.node.version_too_low", version, min_version))
          end

          return if parsed_version[:major].to_i > min_major

          unless min_minor.nil? || parsed_version[:minor].to_i >= min_minor
            context.abort(context.message("features.argo.dependencies.node.version_too_low", version, min_version))
          end
        end
      end
    end
  end
end
