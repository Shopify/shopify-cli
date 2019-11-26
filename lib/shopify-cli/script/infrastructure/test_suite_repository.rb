# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TestSuiteRepository < Repository
        TEST_TEMPLATE_NAME = "template"

        def create_test_suite(script)
          # Remove this once we have a test suite for js
          return unless script.language == "ts"

          root = test_base(script.name)

          FileUtils.mkdir_p(root)
          sample_test = File.read(test_template(script.language))
          FileUtils.copy(aspect_config_template(script.language), "#{root}/as-pect.config.js")
          source = "#{root}/#{script.name}.spec.#{script.language}"
          File.write(source,
            format(sample_test, extension_point_type: script.extension_point.type, script_name: script.name))
          Domain::TestSuite.new(source, script)
        end

        def get_test_suite(language, extension_point_type, script_name)
          script = ScriptRepository.new.get_script(language, extension_point_type, script_name)

          root = test_base(script_name)
          source = "#{root}/#{script_name}.spec.#{language}"
          raise Domain::TestSuiteNotFoundError.new(extension_point_type, script_name) unless File.exist?(source)

          Domain::TestSuite.new(source, script)
        end

        def with_test_suite_context(test_suite)
          root = test_base(test_suite.script.name)
          Dir.chdir(root) do
            yield
          end
        end

        private

        def test_template(language)
          "#{INSTALLATION_BASE_PATH}/templates/#{language}/#{TEST_TEMPLATE_NAME}.spec.#{language}"
        end

        def test_base(script_name)
          "#{format(FOLDER_PATH_TEMPLATE, script_name: script_name)}/test"
        end

        def aspect_config_template(language)
          "#{INSTALLATION_BASE_PATH}/templates/#{language}/as-pect.config.js"
        end
      end
    end
  end
end
