require_relative "../../../ext/shopify-extensions/shopify_extensions"

When('Shopify extensions are installed in the working directory') do
  ShopifyExtensions.install(
    version: "v0.1.0",
    target: File.expand_path("shopify-extensions", @working_dir)
  )
end

Then("I have the right binary for my system's architecture") do
  system_architecture = `uname -m`
  binary_architecture = `file #{File.expand_path("shopify-extensions", @working_dir)}`
  assert binary_architecture.include?(system_architecture)
end