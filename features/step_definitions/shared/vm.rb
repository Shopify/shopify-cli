# frozen_string_literal: true

require "securerandom"
require_relative "../../../utilities/utilities"

Given(/I have a VM with the CLI and a working directory/) do
  @container_id = SecureRandom.hex
  @vm_tmp_dir = "/tmp/#{SecureRandom.hex}"
  Utilities::Docker.run("mkdir", "-p", @vm_tmp_dir, container_id: @container_id)
end

After do |_scenario|
  unless @container_id.nil?
    Utilities::Docker.rm(container_id: @container_id)
  end
end
