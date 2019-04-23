# frozen_string_literal: true
require 'shopify_cli'

module ShopifyCli
  class Project
    class << self
      def current
        at(Dir.pwd)
      end

      def at(dir)
        proj_dir = directory(dir)
        unless proj_dir
          raise(ShopifyCli::Abort, "You are not in a shopify project")
        end
        @at ||= Hash.new { |h, k| h[k] = new(k) }
        @at[proj_dir]
      end

      # Returns the directory of the project you are current in
      # Traverses up directory hierarchy until it finds a `.shopify-cli.json`, then returns the directory is it in
      #
      # #### Example Usage
      # `directory`, e.g. `~/src/Shopify/dev`
      #
      def directory(dir)
        @dir ||= Hash.new { |h, k| h[k] = __directory(k) }
        @dir[dir]
      end

      private

      def __directory(curr)
        loop do
          return nil if curr == '/'
          file = File.join(curr, '.shopify-cli.yml')
          return curr if File.exist?(file)
          curr = File.dirname(curr)
        end
      end
    end

    attr_reader :directory

    def initialize(directory)
      @directory = directory
    end

    def config
      @config ||= begin
        config = load_yaml_file('.shopify-cli.yml', allow_missing: false)
        unless config.is_a?(Hash)
          raise ShopifyCli::Abort, '.shopify-cli.yml was not a proper yaml file. Expecting a hash'
        end
        config
      end
    end

    private

    def load_yaml_file(relative_path, allow_missing: false)
      f = File.join(directory, relative_path)
      require 'yaml' # takes 20ms, so deferred as late as possible.
      begin
        YAML.load_file(f) || {}
      rescue Psych::SyntaxError => e
        raise(ShopifyCli::Abort, "#{relative_path} contains invalid YAML: #{e.message}")
      # rescue Errno::EACCES => e
      # TODO
      #   Dev::Helpers::EaccesHandler.diagnose_and_raise(f, e, mode: :read)
      rescue Errno::ENOENT
        allow_missing ? {} : raise
      end
    end
  end
end
