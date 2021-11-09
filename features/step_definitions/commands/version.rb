Then("'version' returns the right version") do
  output = @container.capture_shopify("version").chomp
  assert_equal CLI.version, output
end

Then(/I can run "(.+)" successfully/) do |command|
  args = command.split(" ")
  @container.exec(*args)
end
