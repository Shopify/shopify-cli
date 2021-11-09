And(/^I build the Ruby Gem as (.+)$/) do |gem_name|
    cli_path = Utilities::Docker::Container::SHOPIFY_PATH
    gemspec_path = File.join(cli_path, "shopify-cli")
    gem_path = File.join(@container.cwd, gem_name)
    @container.exec("gem", "build", gemspec_path, "-o", gem_path, "-C", cli_path)
end
  
When(/^I install the Ruby Gem (.+)$/) do |gem_name|
    gem_path = File.join(@container.cwd, gem_name)
    @container.exec("gem", "install", gem_path)
end

Then(/The (.+) Ruby Gem contains a file (.+)/) do |gem_name, file_path|
    gem_path = File.join(@container.cwd, file_path)
    joined_template_path = File.join(Utilities::Docker::Container::SHOPIFY_PATH, file_path)
    file_content = @container.capture("cat", joined_template_path).chomp
end