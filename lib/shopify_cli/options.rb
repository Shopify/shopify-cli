# frozen_string_literal: true
require "shopify_cli"
require "optparse"

module ShopifyCLI
  class Options
    include SmartProperties

    attr_reader :flags, :subcommand, :help

    def initialize
      @flags = {}
      @help = false
    end

    def parse(options_block, args)
      @args = args
      if options_block.respond_to?(:call) && args
        parse_flags(options_block)
      else
        parser.permute!(@args)
      end
      @args
    end

    def parse_flags(block)
      block.call(parser, @flags)
      parser.permute!(@args)
    end

    def parser
      @parser ||= begin
        opt = OptionParser.new
        opt.on("--help", "-h", Context.message("core.options.help_text")) do |v|
          @help = v
        end
      end
    end
  end
end
