ENV["RUNNING_SHOPIFY_CLI_TESTS"] = 1.to_s

require "rubygems"
require "bundler/setup"
require "shopify_cli"
#require "byebug"
#require "pry"

require "minitest/autorun"
require "minitest/reporters"
require_relative "test_helpers"
require_relative "minitest_ext"
require "fakefs/safe"
require "webmock/minitest"

require "mocha/minitest"

Mocha.configure do |c|
  c.stubbing_non_existent_method = :prevent
  c.stubbing_method_on_nil = :prevent
end

Minitest::Reporters.use!([Minitest::Reporters::DefaultReporter.new(color: true)])

if RUBY_ENGINE == "jruby"
  ObjectSpace.each_object(Module) do |m|
    if m.respond_to?(:constants)
      m.constants(false).each do |c|
        m.const_get(c)
      end
    end
  end
end
