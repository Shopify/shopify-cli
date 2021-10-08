Then("'version' returns the right version") do
  output = Process.capture_shopify(
    "version",
    cwd: @docker_tmp_dir,
    container_id: @docker_container_id
  ).chomp
  assert_equal CLI.version, output
end
