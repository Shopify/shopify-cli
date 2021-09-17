require_relative "./shopify_extensions"

installation_dir = ENV.fetch("SHOPIFY_CLI_EXTENSIONS_INSTALLATION_DIR", __dir__)

File.write(File.expand_path("Makefile", installation_dir), <<~MAKEFILE)
  .PHONY: clean

  clean: ;

  install: ;
MAKEFILE

begin
  ShopifyExtensions.install(
    target: File.expand_path("shopify-extensions", installation_dir)
  )
rescue ShopifyExtensions::InstallationError => error
  STDERR.puts(error.message)
rescue => error
  STDERR.puts("Unable to install shopify-extensions: #{error}")
end
