# frozen_string_literal: true
require 'shopify_cli'
require 'optparse'

module ShopifyCli
  class Options
    include SmartProperties

    attr_reader :flags, :subcommand, :help

    def initialize
      @flags = {}
      @help = false
    end

    def parse(options_block, args)
      @args = args
      parse_flags(options_block) if options_block.respond_to?(:call) && args
      @args
    end

    def parse_flags(block)
      block.call(parser, @flags)
      parser.permute!(@args)
    end

    def parser
      @parser ||= begin
        opt = OptionParser.new
        opt.on('--help', '-h', 'Print help for command') do
          @help = true
        end
      end
    end
  end
end
