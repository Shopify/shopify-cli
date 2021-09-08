Then("version returns the right version") do
  output = Process.capture_shopify("version").chomp
  assert_equal CLI.version, output
end
