# Make sure we are using UTF 8 encoding
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

Thread.report_on_exception = false

# Contains backports from newer rubies to make our lives easier
# require_relative 'support/ruby_backports'

# See bin/load_shopify.rb
ENV["PATH"] = ENV["PATH"].split(":").select { |p| p.start_with?("/", "~") }.join(":") unless defined?($original_env)

# Load vendor and CLI UI/Kit.
# Nothing else should be loaded at this point and nothing else should be added to the load path on boot
vendor_path = File.expand_path("../../vendor/lib", __FILE__)
$LOAD_PATH.unshift(vendor_path) unless $LOAD_PATH.include?(vendor_path)

deps = %w(cli-ui cli-kit smart_properties ruby2_keywords webrick)
deps.each do |dep|
  vendor_path = File.expand_path("../../vendor/deps/#{dep}/lib", __FILE__)
  $LOAD_PATH.unshift(vendor_path) unless $LOAD_PATH.include?(vendor_path)
end

require "ruby2_keywords"
require "cli/ui"
require "cli/kit"
require "smart_properties"
require_relative "shopify_cli/version"
require_relative "shopify_cli/migrator"
require_relative "shopify_cli/exception_reporter"

# Enable stdout routing. At this point all calls to STDOUT (and STDERR) will go through this class.
# See https://github.com/Shopify/cli-ui/blob/main/lib/cli/ui/stdout_router.rb for more info
CLI::UI::StdoutRouter.enable

# The main file to load for `shopify-cli`
# Contains all high level constants, exit management, exception management,
# autoloads for commands, tasks, helpers, etc
#
# It is recommended to read through CLI Kit (https://github.com/shopify/cli-kit) and a CLI Kit example
# (https://github.com/Shopify/cli-kit-example) to fully understand how shopify-cli functions
module ShopifyCLI
  extend CLI::Kit::Autocall

  TOOL_NAME         = "shopify"
  TOOL_FULL_NAME    = "Shopify CLI"
  ROOT              = File.expand_path("../..", __FILE__)
  PROJECT_TYPES_DIR = File.join(ROOT, "lib", "project_types")
  TEMP_DIR          = File.join(ROOT, ".tmp")

  # programmer emoji if default install location, else wrench emoji
  EMOJI    = ROOT == "/opt/shopify" ? "\u{1f469}\u{200d}\u{1f4bb}" : "\u{1f527}"
  # shrug or boom emoji
  FAILMOJI = ROOT == "/opt/shopify" ? "\u{1f937}" : "\u{1f4a5}"

  # Exit management in `shopify-cli` follows the management set out by CLI Kit.
  # https://github.com/Shopify/cli-kit/blob/main/lib/cli/kit.rb
  # That is to say, we differentiate between exit success (0), exit failure (1), and exit bug (not 1)
  #
  # These should *never* be called outside of the entrypoint and its delegations.
  EXIT_FAILURE_BUT_NOT_BUG = CLI::Kit::EXIT_FAILURE_BUT_NOT_BUG
  EXIT_BUG                 = CLI::Kit::EXIT_BUG
  EXIT_SUCCESS             = CLI::Kit::EXIT_SUCCESS

  # `shopify-cli` uses CLI Kit's exception management
  # These are documented here: https://github.com/Shopify/cli-kit/blob/main/lib/cli/kit.rb
  #
  # You should never subclass these exceptions, but instead rescue another exception and re-raise.
  # AbortSilent and BugSilent should never have messages. They are mostly used when we output explanations
  # and need to exit
  GenericAbort = CLI::Kit::GenericAbort
  Abort        = CLI::Kit::Abort
  Bug          = CLI::Kit::Bug
  BugSilent    = CLI::Kit::BugSilent
  AbortSilent  = CLI::Kit::AbortSilent

  # The rest of this file outlines classes and modules required by the shopify-cli
  # application and CLI kit framework.
  # To understand how this works, read https://github.com/Shopify/cli-kit/blob/main/lib/cli/kit.rb

  # ShopifyCLI::Config
  autocall(:Config)   { CLI::Kit::Config.new(tool_name: TOOL_NAME) }
  # ShopifyCLI::Logger
  autocall(:Logger)   { CLI::Kit::Logger.new(debug_log_file: ShopifyCLI.debug_log_file) }
  # ShopifyCLI::Resolver
  autocall(:Resolver) do
    ShopifyCLI::Core::HelpResolver.new(
      tool_name: TOOL_NAME,
      command_registry: ShopifyCLI::Commands::Registry
    )
  end
  # ShopifyCLI::ErrorHandler
  autocall(:ErrorHandler) do
    CLI::Kit::ErrorHandler.new(
      log_file: ShopifyCLI.log_file,
      exception_reporter: ->() { ShopifyCLI::ExceptionReporter },
    )
  end

  autoload :AdminAPI, "shopify_cli/admin_api"
  autoload :API, "shopify_cli/api"
  autoload :AppTypeDetector, "shopify_cli/app_type_detector"
  autoload :Command, "shopify_cli/command"
  autoload :CommandOptions, "shopify_cli/command_options"
  autoload :Commands, "shopify_cli/commands"
  autoload :Connect, "shopify_cli/connect"
  autoload :Constants, "shopify_cli/constants"
  autoload :Context, "shopify_cli/context"
  autoload :Core, "shopify_cli/core"
  autoload :DB, "shopify_cli/db"
  autoload :Environment, "shopify_cli/environment"
  autoload :Feature, "shopify_cli/feature"
  autoload :Form, "shopify_cli/form"
  autoload :Git, "shopify_cli/git"
  autoload :GitHub, "shopify_cli/github"
  autoload :Helpers, "shopify_cli/helpers"
  autoload :Heroku, "shopify_cli/heroku"
  autoload :IdentityAuth, "shopify_cli/identity_auth"
  autoload :JsDeps, "shopify_cli/js_deps"
  autoload :JsSystem, "shopify_cli/js_system"
  autoload :LazyDelegator, "shopify_cli/lazy_delegator"
  autoload :MethodObject, "shopify_cli/method_object"
  autoload :Options, "shopify_cli/options"
  autoload :PartnersAPI, "shopify_cli/partners_api"
  autoload :PHPDeps, "shopify_cli/php_deps"
  autoload :ProcessSupervision, "shopify_cli/process_supervision"
  autoload :Project, "shopify_cli/project"
  autoload :ProjectType, "shopify_cli/project_type"
  autoload :ReportingConfigurationController, "shopify_cli/reporting_configuration_controller"
  autoload :ResolveConstant, "shopify_cli/resolve_constant"
  autoload :Resources, "shopify_cli/resources"
  autoload :Result, "shopify_cli/result"
  autoload :Services, "shopify_cli/services"
  autoload :Shopifolk, "shopify_cli/shopifolk"
  autoload :Task, "shopify_cli/task"
  autoload :Tasks, "shopify_cli/tasks"
  autoload :TransformDataStructure, "shopify_cli/transform_data_structure"
  autoload :Tunnel, "shopify_cli/tunnel"
  autoload :Utilities, "shopify_cli/utilities"

  require "shopify_cli/messages/messages"
  Context.load_messages(ShopifyCLI::Messages::MESSAGES)

  # cli-ui utilities for capturing the output close the stream while capturing.
  # By setting the value here we persist the tty value for the whole lifetime of the process.
  Environment.interactive = $stdin.tty?

  def self.cache_dir
    cache_dir = if Environment.test?
      TEMP_DIR
    elsif ENV["LOCALAPPDATA"].nil?
      File.join(File.expand_path(ENV.fetch("XDG_CACHE_HOME", "~/.cache")), TOOL_NAME)
    else
      File.join(File.expand_path(ENV["LOCALAPPDATA"]), TOOL_NAME)
    end

    # Make sure the cache dir always exists
    @cache_dir_exists ||= FileUtils.mkdir_p(cache_dir)

    cache_dir
  end

  def self.tool_config_path
    if Environment.test?
      TEMP_DIR
    elsif ENV["APPDATA"].nil?
      File.join(File.expand_path(ENV.fetch("XDG_CONFIG_HOME", "~/.config")), TOOL_NAME)
    else
      File.join(File.expand_path(ENV["APPDATA"]), TOOL_NAME)
    end
  end

  def self.log_file
    File.join(tool_config_path, "logs", "log.log")
  end

  def self.debug_log_file
    File.join(tool_config_path, "logs", "debug.log")
  end

  def self.sha
    return @sha if defined?(@sha)
    @sha = Git.sha(dir: ShopifyCLI::ROOT)
  end

  # Migrate runs migrations that migrate the state of the environment
  # in which the CLI runs.
  unless ShopifyCLI::Environment.test? || ShopifyCLI::Environment.development?
    ShopifyCLI::Migrator.migrate
  end
end
