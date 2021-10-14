require_relative "../../../utilities/utilities"

When(/I create a (.+) script named (.+)/) do |extension_point, script_name|
  @container.exec_shopify(
    "script", "create",
    "--name", script_name,
    "--extension-point=#{extension_point}"
  )
end

Then(/I should be able to (.+) the script in directory (.+)/) do |action, directory|
  @container.exec("npm", "run", action, relative_dir: directory)
end
