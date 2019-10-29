# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Domain::TestSuite do
  let(:id) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH}/discount/myscript/myscript.spec.ts" }
  let(:language) { "ts" }
  let(:extension_point_type) { "discount" }
  let(:script_name) { "myscript" }
  let(:configuration_schema) do
    <<~GRAPHQL
      input Configuration {
        _: Boolean
      }

      type Query {
        configuration: Configuration
      }
    GRAPHQL
  end
  let(:configuration) { ShopifyCli::ScriptModule::Domain::Configuration.new("id", "configuration.schema", configuration_schema, "code") }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point_type, configuration, language, "schema") }

  describe ".new" do
    subject { ShopifyCli::ScriptModule::Domain::TestSuite.new(id, script) }

    it "should construct new Script" do
      suite = subject
      assert_equal id, suite.id
      assert_equal script, suite.script
    end
  end
end
