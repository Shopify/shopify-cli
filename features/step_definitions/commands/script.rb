When(/I create a payment method script named (.+)/) do |script_name|
  Process.run_shopify("script", "create", "--name", script_name, "--extension-point=payment_methods",
    cwd: @working_dir)
end

Then(/I should be able to (.+) the script in directory (.+)/) do |action, script_name|
  cwd = File.join(@working_dir, script_name)
  Process.run("yarn", "run", action, cwd: cwd)
end
