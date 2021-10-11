When(/I create a theme named (.+)/) do |theme_name|
  @container.exec_shopify("theme", "init", theme_name)
end

Then(/I should be able to check the theme in directory (.+)/) do |_theme_directory|
  @container.exec_shopify("theme", "check")
end
