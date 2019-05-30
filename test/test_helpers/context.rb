# frozen_string_literal: true
module TestHelpers
  module Context
    def setup
      @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir, env: {
        'HOME' => '~',
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
