require_relative "../../../ext/shopify-extensions/shopify_extensions"
require_relative "../../../lib/shopify_cli"

When("Shopify extensions are installed in the working directory") do
  ShopifyExtensions.install(
    version: "v0.1.0",
    target: File.expand_path("shopify-extensions", @working_dir)
  )
end

Then("I have the right binary for my system's architecture") do
  system_architecture = [%x(uname -m).chomp].flat_map { |arch| [arch, arch.gsub("_", "-")] }
  binary_architecture = %x(file #{File.expand_path("shopify-extensions", @working_dir)})
  assert system_architecture.any? { |arch| binary_architecture.include?(arch) }
end
