# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Commands
    class Deploy < ShopifyCli::Command

      def call(*)
        @project = ExtensionProject.current
        @project.registration_id? ? update_draft : create_extension
      end

      def self.help
        <<~HELP
            Deploy the current packed extension to the Partners Dashboard where it can be Promoted and Published.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy}}
        HELP
      end

      private

      def update_draft
        Tasks::UpdateDraft.call(
          context: @ctx,
          api_key: @project.env['api_key'],
          registration_id: @project.registration_id,
          config: {
            serialized_script: encode_script
          }
        )
      end

      def create_extension
        registration = Tasks::CreateExtension.call(
          context: @ctx,
          api_key: @project.env['api_key'],
          type: @project.extension_type,
          title: 'Testing the CLI',
          config: {
            serialized_script: encode_script
          }
        )

        @project.set_registration_id(@ctx, registration.id)
      end

      def encode_script
        Base64.encode64(File.open("build/main.js").read.chomp)
      end
    end
  end
end
