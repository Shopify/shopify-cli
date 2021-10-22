require_relative "../../../ext/shopify-extensions/shopify_extensions"

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

When(/I build the Ruby Gem as (.+)/) do |gem_name|
  cli_root_path = Utilities::Constants::Paths::ROOT
  gemspec_path = File.join(cli_root_path, "shopify-cli.gemspec")
  gem_output_path = File.join(@working_dir, gem_name)
  Process.run("gem", "build", gemspec_path, "-o", gem_output_path)
end

Then(/The (.+) Ruby Gem contains a file (.+)/) do |gem_name, file_path|
  gem_path = File.join(@working_dir, gem_name)
  uncompressed_gem_path = File.join(@working_dir, "shopify-cli")
  FileUtils.mkdir_p(uncompressed_gem_path)
  data_tar_gz_path = File.join(uncompressed_gem_path, "data.tar.gz")
  uncompressed_data_path = File.join(@working_dir, "data")
  FileUtils.mkdir_p(uncompressed_data_path)

  Process.run("tar", "-xvzf", gem_path, "-C", uncompressed_gem_path)
  Process.run("tar", "-xvzf", data_tar_gz_path, "-C", uncompressed_data_path)

  assert File.exist?(File.join(uncompressed_data_path, file_path))
end

Then("The file `ISSUE_TEMPLATE.md` is retained inside `.github`") do
  issue_template_file_path = File.join(ShopifyCLI::ROOT, ".github/ISSUE_TEMPLATE.md")
  assert File.exist?(issue_template_file_path)
end
