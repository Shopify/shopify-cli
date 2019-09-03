# Make sure we are using UTF 8 encoding
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Contains backports from newer rubies to make our lives easier
# require_relative 'support/ruby_backports'

# See bin/support/load_shopify.rb
# Do it here as well because in some cases, load_dev is not called
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

  TOOL_NAME        = 'shopify'
  TOOL_FULL_NAME   = 'Shopify App CLI'
  VERSION          = 'beta'
  ROOT             = File.expand_path('../..', __FILE__)
  INSTALL_DIR      = File.expand_path('.shopify-app-cli', ENV.fetch('XDG_RUNTIME_DIR', ENV.fetch('HOME')))
  TEMP_DIR         = File.join(ROOT, '.tmp')
  CONFIG_HOME      = File.expand_path(ENV.fetch('XDG_CONFIG_HOME', '~/.config'))
  TOOL_CONFIG_PATH = File.join(CONFIG_HOME, TOOL_NAME)
  LOG_FILE         = File.join(TOOL_CONFIG_PATH, 'logs', 'log.log')
  DEBUG_LOG_FILE   = File.join(TOOL_CONFIG_PATH, 'logs', 'debug.log')

  # programmer emoji if default install location, else wrench emoji
  EMOJI    = ROOT == '/opt/shopify-cli' ? "\u{1f469}\u{200d}\u{1f4bb}" : "\u{1f527}"
  # shrug or boom emoji
  FAILMOJI = ROOT == '/opt/shopify-cli' ? "\u{1f937}" : "\u{1f4a5}"

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
  autocall(:Config)   { CLI::Kit::Config.new(tool_name: TOOL_NAME) }
  autocall(:Logger)   { CLI::Kit::Logger.new(debug_log_file: DEBUG_LOG_FILE) }
  autocall(:Resolver) do
    CLI::Kit::Resolver.new(
      tool_name: TOOL_NAME,
      command_registry: ShopifyCli::Commands::Registry
    )
  end
  autocall(:ErrorHandler) do
    CLI::Kit::ErrorHandler.new(
      log_file: ShopifyCli::LOG_FILE,
      exception_reporter: nil,
    )
  end

  autoload :AppTypes, 'shopify-cli/app_types'
  autoload :AppTypeRegistry, 'shopify-cli/app_type_registry'
  autoload :Command, 'shopify-cli/command'
  autoload :Commands, 'shopify-cli/commands'
  autoload :Context, 'shopify-cli/context'
  autoload :EntryPoint, 'shopify-cli/entry_point'
  autoload :Executor, 'shopify-cli/executor'
  autoload :Finalize, 'shopify-cli/finalize'
  autoload :Helpers, 'shopify-cli/helpers'
  autoload :OAuth, 'shopify-cli/oauth'
  autoload :Options, 'shopify-cli/options'
  autoload :Project, 'shopify-cli/project'
  autoload :SubCommand, 'shopify-cli/sub_command'
  autoload :Task, 'shopify-cli/task'
  autoload :Tasks, 'shopify-cli/tasks'
  autoload :Update, 'shopify-cli/update'
  autoload :Util, 'shopify-cli/util'
end
