When(/I create a theme named (.+)/) do |theme_name|
  Process.exec_shopify(
    "theme", "init",
    theme_name,
    cwd: @docker_tmp_dir,
    container_id: @docker_container_id
  )
end

Then(/I should be able to check the theme in directory (.+)/) do |theme_directory|
  Process.exec_shopify(
    "theme", "check",
    cwd: File.join(@docker_tmp_dir, theme_directory),
    container_id: @docker_container_id
  )
end
