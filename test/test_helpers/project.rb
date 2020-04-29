# frozen_string_literal: true
module TestHelpers
  module Project
    def setup
      super
      @old_pwd = Dir.pwd
      project_context('project')
    end

    def project_context(*dir)
      root = File.join(MiniTest::Test::FIXTURE_DIR, *dir)
      @context = TestHelpers::FakeContext.new(
        root: root,
        env: {
          'HOME' => '~',
          'XDG_CONFIG_HOME' => root,
        }
      )
      ShopifyCli::Context.stubs(:new).returns(@context)
      FileUtils.cd(@context.root)
    end

    def teardown
      @context = nil
      FileUtils.cd(@old_pwd)
      super
    end
  end
end
