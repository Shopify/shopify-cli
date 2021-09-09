# frozen_string_literal: true

require "tmpdir"
require "fileutils"

Given(/I have a working directory/) do
  @working_dir = Dir.mktmpdir
end

After do |_scenario|
  FileUtils.rm_r(@working_dir) unless @working_dir.nil?
end
