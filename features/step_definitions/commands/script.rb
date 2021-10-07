require_relative "../../../utilities/utilities"

When(/I create a (.+) script named (.+)/) do |extension_point, script_name|
  Process.exec_shopify(
    "script", "create",
    "--name", script_name,
    "--extension-point=#{extension_point}",
    cwd: @docker_tmp_dir,
    container_id: @docker_container_id
  )
end

Then(/I should be able to (.+) the script in directory (.+)/) do |action, script_name|
  Utilities::Docker.exec(
    "npm", "run", action,
    cwd: File.join(@docker_tmp_dir, script_name),
    container_id: @docker_container_id
  )
end