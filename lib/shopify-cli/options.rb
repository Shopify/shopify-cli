# frozen_string_literal: true
require 'shopify_cli'
require 'optparse'

module ShopifyCli
  class Options
    include SmartProperties

    attr_reader :flags, :subcommand

    def initialize
      @flags = {}
    end

    def parse(options_block, args)
      @args = args
      parse_subcommand
      parse_flags(options_block) if options_block
    end

    def parse_subcommand
      @subcommand = @args.find do |arg|
        arg.match(/\w/)
      end
      @args.delete(@subcommand)
    end

    def parse_flags(block)
      block.call(parser, @flags)
      parser.parse!(@args)
    end

    def parser
      @parser ||= OptionParser.new
    end
  end
end
