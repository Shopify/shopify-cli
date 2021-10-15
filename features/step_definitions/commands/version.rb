Then("'version' returns the right version") do
  output = @container.capture_shopify("version").chomp
  assert_equal CLI.version, output
end
