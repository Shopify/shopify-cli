# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::Languages::OtherProjectCreator do
  include TestHelpers::FakeFS

  let(:context) { TestHelpers::FakeContext.new }
  let(:fake_capture2e_response) { [nil, OpenStruct.new(success?: true)] }

  let(:type) { "payment-methods" }
  let(:language) { "other" }
  let(:domain) { "fake-domain" }
  let(:project_name) { "myscript" }
  let(:sparse_checkout_repo) { nil }
  let(:sparse_checkout_branch) { "fake-branch" }
  let(:sparse_checkout_set_path) { "#{domain}/#{language}/#{type}/default" }

  let(:config_file_content) do
    <<~END
      ---
      version: '2'
      title: #{type} script
      description: #{type} script in other language
      configuration:
      type: object
      fields: {}
    END
  end

  let(:metadata_file_content) do
    "{\"schemaVersions\":{\"#{type}\":{\"major\":1,\"minor\":0}},\"flags\":{\"use_msgpack\":true}}"
  end

  let(:project_creator) do
    Script::Layers::Infrastructure::Languages::OtherProjectCreator
      .new(
        ctx: context,
        type: type,
        project_name: project_name,
        path_to_project: project_name,
        sparse_checkout_repo: sparse_checkout_repo,
        sparse_checkout_branch: sparse_checkout_branch,
        sparse_checkout_set_path: sparse_checkout_set_path,
      )
  end

  describe ".setup_dependencies" do
    subject { project_creator.setup_dependencies }

    it "should setup basic script project files" do
      refute File.file?(Script::Layers::Infrastructure::Languages::OtherProjectCreator.config_file)
      refute File.file?(Script::Layers::Infrastructure::Languages::OtherProjectCreator.metadata_file)

      subject

      assert File.file?(Script::Layers::Infrastructure::Languages::OtherProjectCreator.config_file)
      written_config = File.open(Script::Layers::Infrastructure::Languages::OtherProjectCreator.config_file).read
      assert_equal config_file_content, written_config

      assert File.file?(Script::Layers::Infrastructure::Languages::OtherProjectCreator.metadata_file)
      written_metadata = File.open(Script::Layers::Infrastructure::Languages::OtherProjectCreator.metadata_file).read
      assert_equal metadata_file_content, written_metadata
    end
  end
end
