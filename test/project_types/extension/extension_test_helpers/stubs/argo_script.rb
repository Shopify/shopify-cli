# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module ArgoScript
        TEMPLATE_SCRIPT = <<~SCRIPT
            import React from 'react';
            import {render, ExtensionPoint} from '@shopify/app-extensions-renderer';
            import {Card} from '@shopify/app-extensions-polaris-components/dist/client';
            
            render(ExtensionPoint.AppLink, () => <App />);
            
            function App() {
              return (
                <Card title="Hello world" sectioned>From my app.</Card>
              );
            }
        SCRIPT

        def with_stubbed_script(script: TEMPLATE_SCRIPT)
          base_folder = "extension_test_" + SecureRandom.uuid.to_str

          FileUtils.mkdir_p("#{base_folder}/build")
          FileUtils.cd(base_folder)
          File.open('build/main.js', 'w+') { |file| file.puts(script) }
          yield
        ensure
          FileUtils.cd('..')
          FileUtils.rm_r(base_folder)
        end
      end
    end
  end
end
