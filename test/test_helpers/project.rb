# typed: ignore
# frozen_string_literal: true
module TestHelpers
  module Project
    def setup
      project_context("project")
      super
    end

    def project_context(*dir)
      root = File.join(MiniTest::Test::FIXTURE_DIR, *dir)
      @context = TestHelpers::FakeContext.new(
        root: root,
        env: {
          "HOME" => "~",
          "XDG_CONFIG_HOME" => root,
        }
      )
      FileUtils.cd(@context.root)
    end

    def teardown
      @context = nil
      FileUtils.cd("/")
      super
    end
  end
end
