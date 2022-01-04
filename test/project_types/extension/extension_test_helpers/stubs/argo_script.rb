# typed: false
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

        def with_stubbed_script(context, path, script = TEMPLATE_SCRIPT)
          filepath = File.join(context.root, path)
          directory = File.dirname(filepath)

          FileUtils.mkdir_p(directory)
          File.open(filepath, "w+") { |file| file.puts(script) }
          yield
        ensure
          FileUtils.rm_r(directory)
        end
      end
    end
  end
end
