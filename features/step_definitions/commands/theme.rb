When(/I create a theme named (.+)/) do |theme_name|
  Process.run_shopify("theme", "init", theme_name, cwd: @working_dir)
end

Then(/I should be able to check the theme in directory (.+)/) do |theme_name|
  cwd = File.join(@working_dir, theme_name)
  Process.run_shopify("theme", "check", cwd: cwd)
end
