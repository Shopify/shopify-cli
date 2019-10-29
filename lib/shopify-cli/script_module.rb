require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      autoload :Bootstrap, "shopify-cli/script/application/bootstrap.rb"
      autoload :Build, "shopify-cli/script/application/build.rb"
      autoload :Deploy, "shopify-cli/script/application/deploy.rb"
      autoload :GenerateFromSchema, "shopify-cli/script/application/generate_from_schema.rb"
      autoload :Test, "shopify-cli/script/application/test.rb"
    end

    module Domain
      autoload :Script, "shopify-cli/script/domain/script.rb"
      autoload :ExtensionPoint, "shopify-cli/script/domain/extension_point.rb"
      autoload :ExtensionPointService, "shopify-cli/script/domain/extension_point_service.rb"
      autoload :DeployPackage, "shopify-cli/script/domain/deploy_package.rb"
      autoload :Configuration, "shopify-cli/script/domain/configuration.rb"
      autoload :TestSuite, "shopify-cli/script/domain/test_suite.rb"

      autoload :InvalidExtensionPointError, "shopify-cli/script/domain/errors/invalid_extension_point_error.rb"
      autoload :ScriptNotFoundError, "shopify-cli/script/domain/errors/script_not_found_error.rb"
      autoload :ConfigurationFileNotFoundError, "shopify-cli/script/domain/errors/configuration_file_not_found_error.rb"
      autoload :ServiceFailureError, "shopify-cli/script/domain/errors/service_failure_error.rb"
      autoload :InvalidConfigurationSchemaError, "shopify-cli/script/domain/errors/invalid_configuration_schema_error.rb"
      autoload :TestSuiteNotFoundError, "shopify-cli/script/domain/errors/test_suite_not_found_error.rb"
      autoload :WasmNotFoundError, "shopify-cli/script/domain/errors/wasm_not_found_error.rb"
    end

    module Infrastructure
      autoload :Repository, "shopify-cli/script/infrastructure/repository.rb"
      autoload :ExtensionPointRepository, "shopify-cli/script/infrastructure/extension_point_repository.rb"
      autoload :ScriptRepository, "shopify-cli/script/infrastructure/script_repository.rb"
      autoload :ConfigurationRepository, "shopify-cli/script/infrastructure/configuration_repository.rb"
      autoload :DeployPackageRepository, "shopify-cli/script/infrastructure/deploy_package_repository.rb"
      autoload :TestSuiteRepository, "shopify-cli/script/infrastructure/test_suite_repository.rb"

      autoload :ScriptService, "shopify-cli/script/infrastructure/script_service.rb"

      autoload :TypeScriptWasmBuilder, "shopify-cli/script/infrastructure/typescript_wasm_builder.rb"
      autoload :GraphQLTypeScriptBuilder, "shopify-cli/script/infrastructure/graphql_typescript_builder.rb"
      autoload :TypeScriptWasmTestRunner, "shopify-cli/script/infrastructure/typescript_wasm_test_runner.rb"

      # errors
      autoload :ScriptServiceConnectionError, "shopify-cli/script/infrastructure/errors/script_service_connection_error.rb"
    end
  end
end
