Then("'version' returns the right version") do
  output = @container.capture_shopify("version").chomp
  assert_equal CLI.version, output
end

And(/^I build the Shopify CLI Gem as (.+)$/) do |gem_name|
  cli_path = Utilities::Docker::Container::SHOPIFY_PATH
  gemspec_path = File.join(cli_path, "shopify-cli")
  gem_path = File.join(@container.cwd, gem_name)
  @container.exec("gem", "build", gemspec_path, "-o", gem_path, "-C", cli_path)
end

When(/^I install the Ruby Gem (.+)$/) do |gem_name|
  gem_path = File.join(@container.cwd, gem_name)
  @container.exec("gem", "install", gem_path)
end

Then(/I can run "(.+)" successfully/) do |command|
  args = command.split(" ")
  @container.exec(*args)
end
