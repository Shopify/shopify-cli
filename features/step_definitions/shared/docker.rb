# frozen_string_literal: true

require "securerandom"
require_relative "../../../utilities/utilities"

Given(/I have a VM with the CLI and a working directory/) do
  @container = Utilities::Docker.create_container(env: { "SHOPIFY_CLI_ACCEPTANCE_TEST" => "1" })
  @container_shopify_config_path = File.join(@container.xdg_config_home, "shopify/config")
end

After do |_scenario|
  @container&.remove
end
