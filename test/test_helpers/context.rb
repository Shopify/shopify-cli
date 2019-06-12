# frozen_string_literal: true
module TestHelpers
  module Context
    def setup
      root = Dir.mktmpdir
      @context = TestHelpers::FakeContext.new(root: root, env: {
        'HOME' => '~',
        'XDG_CONFIG_HOME' => root,
      })
      FileUtils.touch(File.join(@context.root, '.shopify-cli.yml'))
      super
      FileUtils.cd(@context.root)
    end

    def teardown
      @context = nil
      FileUtils.cd('/')
      super
    end
  end
end
