module Extension
  module Tasks
    class FindNpmPackages
      include ShopifyCli::MethodObject

      Package = Struct.new(:name, :version)

      property! :js_system, accepts: ShopifyCli::JsSystem

      def self.at_least_one_of(*package_names, **config)
        new(**config).at_least_one_of(*package_names)
      end

      def self.all(*package_names, **config)
        new(**config).all(*package_names)
      end

      def all(*package_names)
        call(*package_names) do |found_packages|
          found_package_names = found_packages.map(&:name)
          next found_packages if Set.new(found_package_names) == Set.new(package_names)
          raise PackageNotFound, format(
            "Missing packages: %s",
            (package_names - found_package_names).join(", ")
          )
        end
      end

      def at_least_one_of(*package_names)
        call(*package_names) do |found_packages|
          found_package_names = found_packages.map(&:name)
          next found_packages unless (found_package_names & package_names).empty?
          raise PackageNotFound, format(
            "Expected at least one of the following packages: %s",
            package_names.join(", ")
          )
        end
      end

      def call(*package_names, &validate)
        validate ||= ->(found_packages) { found_packages }

        unless package_names.all? { |name| name.is_a?(String) }
          raise ArgumentError, "Expected a list of package names"
        end

        ShopifyCli::Result
          .call(&method(:list_packages))
          .then(&method(:search_packages).curry[package_names])
          .then(&validate)
      end

      def list_packages
        result, error, status =
          js_system.call(yarn: yarn_list, npm: npm_list, capture_response: true)
        raise error unless status.success?
        result
      end

      def yarn_list
        %w[list --production]
      end

      def npm_list
        %w[list --prod --depth=1]
      end

      def search_packages(packages, package_list)
        pattern = /(#{packages.join("|")})@(\d.*)$/
        package_list.scan(pattern).map do |(name, version)|
          Package.new(name, version.strip)
        end
      end
    end
  end
end
