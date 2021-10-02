module Extension
  module Tasks
    class FindNpmPackages
      include ShopifyCLI::MethodObject

      property! :js_system, accepts: ShopifyCLI::JsSystem
      property! :production_only, accepts: [true, false], default: false, reader: :production_only?

      def self.at_least_one_of(*package_names, **config)
        new(**config).at_least_one_of(*package_names)
      end

      def self.all(*package_names, **config)
        new(**config).all(*package_names)
      end

      def self.exactly_one_of(*package_names, **config)
        new(**config).exactly_one_of(*package_names)
      end

      def all(*package_names)
        call(*package_names) do |found_packages|
          found_package_names = found_packages.map(&:name)
          next found_packages if Set.new(found_package_names) == Set.new(package_names)
          raise PackageResolutionFailed, format(
            "Missing packages: %s",
            (package_names - found_package_names).join(", ")
          )
        end
      end

      def at_least_one_of(*package_names)
        call(*package_names) do |found_packages|
          found_package_names = found_packages.map(&:name)
          next found_packages unless (found_package_names & package_names).empty?
          raise PackageResolutionFailed, format(
            "Expected at least one of the following packages: %s",
            package_names.join(", ")
          )
        end
      end

      def exactly_one_of(*package_names)
        call(*package_names) do |found_packages|
          case found_packages.count
          when 0
            raise PackageResolutionFailed, format(
              "Expected one of the following packages: %s",
              package_names.join(", ")
            )
          when 1
            found_packages.first.tap do |found_package|
              next found_package if package_names.include?(found_package.name)
              raise PackageResolutionFailed, format(
                "Expected the following package: %s",
                found_package.name
              )
            end
          else
            raise PackageResolutionFailed, "Found more than one package"
          end
        end
      end

      def call(*package_names, &validate)
        validate ||= ->(found_packages) { found_packages }

        unless package_names.all? { |name| name.is_a?(String) }
          raise ArgumentError, "Expected a list of package names"
        end

        ShopifyCLI::Result
          .call(&method(:list_packages))
          .then(&method(:search_packages).curry[package_names])
          .then(&method(:filter_duplicates))
          .then(&validate)
      end

      def list_packages
        result, error, status =
          js_system.call(yarn: yarn_list, npm: npm_list, capture_response: true)
        raise error unless status.success?
        result
      end

      def yarn_list
        production_only? ? %w[list --production --depth=0] : %w[list]
      end

      def npm_list
        production_only? ? %w[list --prod --depth=0] : %w[list]
      end

      def search_packages(packages, package_list)
        pattern = /(#{packages.join("|")})@(\d.*)$/
        package_list.scan(pattern).map do |(name, version)|
          Models::NpmPackage.new(name: name, version: version.strip)
        end
      end

      def filter_duplicates(packages)
        packages.reject { |p| p.version.match(/deduped/) }.uniq
      end
    end
  end
end
