require_relative "../../../utilities/utilities"

When(/I create a rails app named (.+) in the VM/) do |app_name|
  @app_name = app_name
  @container.exec_shopify(
    "rails", "create",
    "--name", app_name,
    "--db", "sqlite3",
  )
end

Then(/the app has an environment file with (.+) set to (.+)/) do |key, value|
  generated_env_file_path = File.join(@app_name, ".env")

  env_file_content = @container.capture("cat", generated_env_file_path).chomp
  env_value = Hash[env_file_content.each_line.map { |l| l.chomp.split("=", 2) }]

  assert env_value[key], value
end
