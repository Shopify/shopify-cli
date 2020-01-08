module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TypeScriptDependencyManager
        def initialize(ctx, script_name, language)
          @ctx = ctx
          @language = language
          @script_name = script_name
        end

        def installed?
          # Assuming if node_modules folder exist at root of script folder, all deps are installed
          Dir.exist?("node_modules")
        end

        def install
          write_package_json
          ShopifyCli::Tasks::JsDeps.call(@ctx)
        end

        private

        def write_package_json
          package_json = <<~HERE
          {
            "name": "#{@script_name}",
            "version": "1.0.0",
            "devDependencies": {
              "@as-pect/assembly": "^2.6.0",
              "@as-pect/cli": "^2.6.0",
              "@as-pect/core": "^2.6.0",
              "assemblyscript": "0.8.0",
              "ts-node": "^8.5.4",
              "typescript": "^3.7.3"
            },
            "scripts": {
              "test": "asp --config test/as-pect.config.js"
            }
          }
          HERE

          File.write("package.json", package_json)
        end
      end
    end
  end
end
