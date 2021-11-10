require_relative "../../../utilities/utilities"

When(/I create a rails app named (.+) in the VM/) do |app_name|
  @app_name = app_name
  @container.exec_shopify(
    "app", "create", "rails",
    "--name", app_name,
    "--db", "sqlite3",
  )
end

When(/I create a node app named (.+) in the VM/) do |app_name|
  @app_name = app_name
  @container.exec_shopify(
    "app", "create", "node",
    "--name", app_name,
  )
end

Then(/the app has an environment file with (.+) set to (.+)/) do |key, value|
  generated_env_file_path = File.join(@app_name, ".env")

  env_file_content = @container.capture("cat", generated_env_file_path).chomp
  env_value = Hash[env_file_content.each_line.map { |l| l.chomp.split("=", 2) }]

  assert env_value[key], value
end

Then(/the app has a yaml file to specify a (.+) project type/) do |project_type|
  generated_yaml_file_path = File.join(@app_name, ".shopify-cli.yml")

  yaml_file_content = @container.capture("cat", generated_yaml_file_path).chomp
  project_config = YAML.load(yaml_file_content)

  assert project_config["project_type"], project_type
end
