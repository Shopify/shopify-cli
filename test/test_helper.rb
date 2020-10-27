ENV['RUNNING_SHOPIFY_CLI_TESTS'] = 1.to_s

require 'rubygems'
require 'bundler/setup'
require 'shopify_cli'
require 'byebug'
require 'pry'

require 'minitest/autorun'
require 'minitest/reporters'
require_relative 'test_helpers'
require_relative 'minitest_ext'
require 'fakefs/safe'
require 'webmock/minitest'

require 'mocha/minitest'
