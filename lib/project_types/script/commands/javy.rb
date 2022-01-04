# typed: ignore
# frozen_string_literal: true
require "shopify_cli"
require_relative "../../../../ext/javy/javy.rb"

module Script
  class Command
    class Javy < ShopifyCLI::Command::SubCommand
      hidden_feature

      options do |parser, flags|
        parser.on("--in=IN") { |in_file| flags[:in_file] = in_file }
        parser.on("--out=OUT") { |out_file| flags[:out_file] = out_file }
      end

      def call(*)
        source = options.flags[:in_file]
        dest = options.flags[:out_file]

        @ctx.abort(@ctx.message("script.javy.errors.invalid_arguments", ShopifyCLI::TOOL_NAME)) unless source

        ::Javy.build(source: source, dest: dest).unwrap { |e| @ctx.abort(e.message) }
      end

      def self.help
        ShopifyCLI::Context.message("script.javy.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
