# frozen_string_literal: true

require "securerandom"
require_relative "../../../utilities/utilities"

Given(/I have a VM with the CLI and a working directory/) do
  @docker_container_id = SecureRandom.hex
  @docker_tmp_dir = "/tmp/#{SecureRandom.hex}"
  Utilities::Docker.run(
    "tail", "-f", "/dev/null",
    container_id: @docker_container_id
  )
  Utilities::Docker.exec(
    "mkdir", "-p", @docker_tmp_dir,
    container_id: @docker_container_id
  )
end

After do |_scenario|
  unless @docker_container_id.nil?
    Utilities::Docker.rm(container_id: @docker_container_id)
  end
end
