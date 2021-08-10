# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator do
  include TestHelpers::FakeFS

  let(:script_name) { "myscript" }
  let(:language) { "AssemblyScript" }
  let(:script_id) { "id" }
  let(:context) { TestHelpers::FakeContext.new }
  let(:extension_point_type) { "payment_methods" }
  let(:extension_point) { Script::Layers::Domain::ExtensionPoint.new(extension_point_type, extension_point_config) }
  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::AssemblyScriptProjectCreator
      .new(ctx: context, extension_point: extension_point, script_name: script_name, path_to_project: script_name)
  end
  let(:extension_point_config) do
    {
      "assemblyscript" => {
        "repo" => "https://github.com/Shopify/extension-points.git",
        "package" => "@shopify/extension-point-as-fake",
        "sdk-version" => "*",
        "toolchain-version" => "*",
      },
    }
  end
  let(:fake_capture2e_response) { [nil, OpenStruct.new(success?: true)] }

  before do
    context.mkdir_p(script_name)
  end

  def system_output(msg:, success:)
    [msg, OpenStruct.new(success?: success)]
  end
  
end
