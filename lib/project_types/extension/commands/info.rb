# frozen_string_literal: true
require "shopify_cli"

module Extension
  class Command
    class Info < ExtensionCommand
      hidden_feature

      def call(*)
        @ctx.puts("Extension Title: #{project.title}")
        @ctx.puts("Extension UUID: #{project.registration_uuid}")
        @ctx.puts("Extension ID: #{project.registration_id}")
        theme_app_extension_additional_info
      end

      def self.help
        ShopifyCLI::Context.new.message("info.help", ShopifyCLI::TOOL_NAME)
      end

      private

      OPENING_SCHEMA = "{%schema%}"
      CLOSING_SCHEMA = "{%endschema%}"

      def theme_app_extension_additional_info
        if project.specification_identifier == "THEME_APP_EXTENSION" && (infos = block_infos)
          title = to_handle(app.title)
          uuid = project.registration_uuid
          @ctx.puts("Block Infos \n")
          index = 1
          infos.each do |type, blocks_name|
            @ctx.puts(" << #{type} >>\n")
            blocks_name.each do |block_name|
              @ctx.puts(" #{index}. shopify://apps/#{title}/blocks/#{block_name}/#{uuid} \n")
              index += 1
            end
          end
        end
      end

      def app
        @app ||= Tasks::GetApp.call(context: @ctx, api_key: project.app.api_key)
      end

      def block_infos
        block_infos = {}
        Dir["blocks/*.liquid"].map do |filename|
          block_name = File.basename(filename, ".liquid")
          json_schema = block_info(filename)

          next unless json_schema
          block_type = json_schema["target"] == "section" ? "App Block" : "App Embed"
          block_infos[block_type] ||= []
          block_infos[block_type] << block_name
        end
        block_infos
      end

      def block_info(filename)
        output = File.read(filename)
        output = output.gsub(/\s+/, "")

        if output
          opening_index = output.index(OPENING_SCHEMA) + OPENING_SCHEMA.size
          closing_index = output.index(CLOSING_SCHEMA) - 1

          if (schema = output.slice(opening_index..closing_index))
            json_schema = JSON.parse(schema)
          end
        end
        json_schema
      rescue JSON::ParserError
        {}
      end

      def to_handle(s)
        s = s.dup
        s.downcase!
        s.delete!("'\"()[]")
        s.gsub!(/\W+/, "-")
        s.gsub!(/\A-+|-+\z/, "")
        -s
      end
    end
  end
end
