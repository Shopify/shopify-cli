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

      def call(_args, _)
        @ctx.abort(@ctx.message("script.deprecated"))
      end

      def self.help
        ShopifyCLI::Context.new.message("script.deprecated")
      end
    end
  end
end
