require 'test_helper'

module ShopifyCli
  module Commands
    class Create
      class ExtensionTest < MiniTest::Test
        def test_prints_help_with_no_name_argument
          io = capture_io { run_cmd('create extension') }
          assert_match(CLI::UI.fmt(ShopifyCli::Commands::Create::Extension.help), io.join)
        end

        def test_clones_project_template
          ShopifyCli::Tasks::Clone
            .expects(:call)
            .with('https://github.com/Shopify/shopify-app-extension-template.git', 'myext')
            .add_side_effect(CreateFakeExtensionProject.new)

          ShopifyCli::Tasks::JsDeps.expects(:call).add_side_effect(CreateDummyLockfile.new)
          ShopifyCli::Finalize.expects(:request_cd).with('myext')

          capture_io { run_cmd('create extension myext --type product-details') }

          refute File.exists?('myext/.git'), 'Expected .git directory to be removed'
          lockfile_content = File.read('myext/yarn.lock')
          assert_equal lockfile_content, '# Dummy lockfile'
        ensure
          FileUtils.rm_r('myext')
        end
      end
    end
  end
end

class CreateFakeExtensionProject
  def perform
    FileUtils.mkdir('myext')
    FileUtils.mkdir('myext/.git')
    File.open('myext/package.json', 'w') { |f| f.puts('{}') }
    FileUtils.touch('myext/yarn.lock')
  end
end

class CreateDummyLockfile
  def perform
    File.open('myext/yarn.lock', "w") { |f| f.write("# Dummy lockfile") }
  end
end

