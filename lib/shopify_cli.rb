# Make sure we are using UTF 8 encoding
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

Thread.report_on_exception = false

# Contains backports from newer rubies to make our lives easier
# require_relative 'support/ruby_backports'

# See bin/load_shopify.rb
ENV['PATH'] = ENV['PATH'].split(':').select { |p| p.start_with?('/', '~') }.join(':') unless defined?($original_env)

# Load vendor and CLI UI/Kit.
# Nothing else should be loaded at this point and nothing else should be added to the load path on boot
vendor_path = File.expand_path("../../vendor/lib", __FILE__)
$LOAD_PATH.unshift(vendor_path) unless $LOAD_PATH.include?(vendor_path)

deps = %w(cli-ui cli-kit smart_properties)
deps.each do |dep|
  vendor_path = File.expand_path("../../vendor/deps/#{dep}/lib", __FILE__)
  $LOAD_PATH.unshift(vendor_path) unless $LOAD_PATH.include?(vendor_path)
end

require 'cli/ui'
require 'cli/kit'
require 'smart_properties'
require_relative 'shopify-cli/version'

# Enable stdout routing. At this point all calls to STDOUT (and STDERR) will go through this class.
# See https://github.com/Shopify/cli-ui/blob/master/lib/cli/ui/stdout_router.rb for more info
CLI::UI::StdoutRouter.enable

# The main file to load for `shopify-app-cli`
# Contains all high level constants, exit management, exception management,
# autoloads for commands, tasks, helpers, etc
#
# It is recommended to read through CLI Kit (https://github.com/shopify/cli-kit) and a CLI Kit example
# (https://github.com/Shopify/cli-kit-example) to fully understand how shopify-app-cli functions
module ShopifyCli
  extend CLI::Kit::Autocall

  TOOL_NAME         = 'shopify'
  TOOL_FULL_NAME    = 'Shopify CLI'
  ROOT              = File.expand_path('../..', __FILE__)
  PROJECT_TYPES_DIR = File.join(ROOT, 'lib', 'project_types')
  TEMP_DIR          = File.join(ROOT, '.tmp')

  # programmer emoji if default install location, else wrench emoji
  EMOJI    = ROOT == '/opt/shopify' ? "\u{1f469}\u{200d}\u{1f4bb}" : "\u{1f527}"
  # shrug or boom emoji
  FAILMOJI = ROOT == '/opt/shopify' ? "\u{1f937}" : "\u{1f4a5}"

  # Exit management in `shopify-app-cli` follows the management set out by CLI Kit.
  # https://github.com/Shopify/cli-kit/blob/master/lib/cli/kit.rb
  # That is to say, we differentiate between exit success (0), exit failure (1), and exit bug (not 1)
  #
  # These should *never* be called outside of the entrypoint and its delegations.
  EXIT_FAILURE_BUT_NOT_BUG = CLI::Kit::EXIT_FAILURE_BUT_NOT_BUG
  EXIT_BUG                 = CLI::Kit::EXIT_BUG
  EXIT_SUCCESS             = CLI::Kit::EXIT_SUCCESS

  # `shopify-app-cli` uses CLI Kit's exception management
  # These are documented here: https://github.com/Shopify/cli-kit/blob/master/lib/cli/kit.rb
  #
  # You should never subclass these exceptions, but instead rescue another exception and re-raise.
  # AbortSilent and BugSilent should never have messages. They are mostly used when we output explanations
  # and need to exit
  GenericAbort = CLI::Kit::GenericAbort
  Abort        = CLI::Kit::Abort
  Bug          = CLI::Kit::Bug
  BugSilent    = CLI::Kit::BugSilent
  AbortSilent  = CLI::Kit::AbortSilent

  # The rest of this file outlines classes and modules required by the shopify-app-cli
  # application and CLI kit framework.
  # To understand how this works, read https://github.com/Shopify/cli-kit/blob/master/lib/cli/kit.rb

  # ShopifyCli::Config
  autocall(:Config)   { CLI::Kit::Config.new(tool_name: TOOL_NAME) }
  # ShopifyCli::Logger
  autocall(:Logger)   { CLI::Kit::Logger.new(debug_log_file: ShopifyCli.debug_log_file) }
  # ShopifyCli::Resolver
  autocall(:Resolver) do
    ShopifyCli::Core::HelpResolver.new(
      tool_name: TOOL_NAME,
      command_registry: ShopifyCli::Commands::Registry
    )
  end
  # ShopifyCli::ErrorHandler
  autocall(:ErrorHandler) do
    CLI::Kit::ErrorHandler.new(
      log_file: ShopifyCli.log_file,
      exception_reporter: nil,
    )
  end

  autoload :AdminAPI, 'shopify-cli/admin_api'
  autoload :API, 'shopify-cli/api'
  autoload :Command, 'shopify-cli/command'
  autoload :Commands, 'shopify-cli/commands'
  autoload :Context, 'shopify-cli/context'
  autoload :Core, 'shopify-cli/core'
  autoload :DB, 'shopify-cli/db'
  autoload :Feature, 'shopify-cli/feature'
  autoload :Form, 'shopify-cli/form'
  autoload :Git, 'shopify-cli/git'
  autoload :Helpers, 'shopify-cli/helpers'
  autoload :Heroku, 'shopify-cli/heroku'
  autoload :JsDeps, 'shopify-cli/js_deps'
  autoload :JsSystem, 'shopify-cli/js_system'
  autoload :Log, 'shopify-cli/log'
  autoload :OAuth, 'shopify-cli/oauth'
  autoload :Options, 'shopify-cli/options'
  autoload :PartnersAPI, 'shopify-cli/partners_api'
  autoload :ProcessSupervision, 'shopify-cli/process_supervision'
  autoload :Project, 'shopify-cli/project'
  autoload :ProjectType, 'shopify-cli/project_type'
  autoload :Resources, 'shopify-cli/resources'
  autoload :Shopifolk, 'shopify-cli/shopifolk'
  autoload :SubCommand, 'shopify-cli/sub_command'
  autoload :Task, 'shopify-cli/task'
  autoload :Tasks, 'shopify-cli/tasks'
  autoload :Tunnel, 'shopify-cli/tunnel'

  require 'shopify-cli/messages/messages'
  Context.load_messages(ShopifyCli::Messages::MESSAGES)

  def self.cache_dir
    cache_dir = if ENV.key?('RUNNING_SHOPIFY_CLI_TESTS')
      TEMP_DIR
    elsif ENV['LOCALAPPDATA'].nil?
      File.join(File.expand_path(ENV.fetch('XDG_CACHE_HOME', '~/.cache')), TOOL_NAME)
    else
      File.join(File.expand_path(ENV['LOCALAPPDATA']), TOOL_NAME)
    end

    # Make sure the cache dir always exists
    @cache_dir_exists ||= FileUtils.mkdir_p(cache_dir)

    cache_dir
  end

  def self.tool_config_path
    if ENV.key?('RUNNING_SHOPIFY_CLI_TESTS')
      TEMP_DIR
    elsif ENV['APPDATA'].nil?
      File.join(File.expand_path(ENV.fetch('XDG_CONFIG_HOME', '~/.config')), TOOL_NAME)
    else
      File.join(File.expand_path(ENV['APPDATA']), TOOL_NAME)
    end
  end

  def self.log_file
    File.join(tool_config_path, 'logs', 'log.log')
  end

  def self.tips_file
    File.join(tool_config_path, 'tips.json')
  end

  def self.debug_log_file
    File.join(tool_config_path, 'logs', 'debug.log')
  end
end
