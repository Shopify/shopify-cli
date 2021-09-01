require_relative "./shopify_extensions"

File.write("Makefile", <<~MAKEFILE)
  .PHONY: clean

  clean: ;

  install: ;
MAKEFILE

begin
  ShopifyExtensions.install(
    version: "v0.1.0",
    target: File.join(File.dirname(__FILE__), "shopify-extensions")
  )
rescue ShopifyExtensions::InstallationError => error
  STDERR.puts(error.message)
rescue => error
  STDERR.puts("Unable to install shopify-extensions: #{error}")
end
