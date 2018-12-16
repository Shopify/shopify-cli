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

deps = %w(cli-ui cli-kit)
deps.each do |dep|
  vendor_path = File.expand_path("../../vendor/deps/#{dep}/lib", __FILE__)
  $LOAD_PATH.unshift(vendor_path) unless $LOAD_PATH.include?(vendor_path)
end

require 'cli/ui'
require 'cli/kit'

# Checks for conflicts with tools like RVM and Rbenv, etc.
# Will exit if needed
# require_relative 'dev/tool_conflicts'
# Dev::ToolConflicts.check

# Defines register commands for init scripts
require 'shopify-cli/register'
require 'shopify-cli/commands'

# Enable stdout routing. At this point all calls to STDOUT (and STDERR) will go through this class.
# See https://github.com/Shopify/cli-ui/blob/master/lib/cli/ui/stdout_router.rb for more info
CLI::UI::StdoutRouter.enable

# The main file to load for `dev`
# Contains all high level constants, exit management, exception management,
# autoloads for commands, tasks, helpers, etc
#
# It is recommended to read through CLI Kit (https://github.com/shopify/cli-kit) and a CLI Kit example
# (https://github.com/Shopify/cli-kit-example) to fully understand how dev functions
module ShopifyCli
  extend CLI::Kit::Autocall

  TOOL_NAME        = 'shopify'
  ROOT             = File.expand_path('../..', __FILE__)
  CONFIG_HOME      = File.expand_path(ENV.fetch('XDG_CONFIG_HOME', '~/.config'))
  TOOL_CONFIG_PATH = File.join(CONFIG_HOME, TOOL_NAME)
  LOG_FILE         = File.join(TOOL_CONFIG_PATH, 'logs', 'log.log')
  DEBUG_LOG_FILE   = File.join(TOOL_CONFIG_PATH, 'logs', 'debug.log')

  # programmer emoji if default install location, else wrench emoji
  EMOJI    = ROOT == '/opt/shopify-cli' ? "\u{1f469}\u{200d}\u{1f4bb}" : "\u{1f527}"
  # shrug or boom emoji
  FAILMOJI = ROOT == '/opt/shopify-cli' ? "\u{1f937}" : "\u{1f4a5}"

  # Exit management in `dev` follows the management set out by CLI Kit.
  # https://github.com/Shopify/cli-kit/blob/master/lib/cli/kit.rb
  # That is to say, we differentiate between exit success (0), exit failure (1), and exit bug (not 1)
  #
  # These should *never* be called outside of the entrypoint and its delegations.
  EXIT_FAILURE_BUT_NOT_BUG = CLI::Kit::EXIT_FAILURE_BUT_NOT_BUG
  EXIT_BUG                 = CLI::Kit::EXIT_BUG
  EXIT_SUCCESS             = CLI::Kit::EXIT_SUCCESS

  # `dev` uses CLI Kit's exception management
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

  # These are the currently standard versions of various languages.
  # New projects will be initialized using these
  FEATURE_VERSIONS = {
    'go' => '1.9',
    'ruby' => '2.5.3',
    'node' => 'v8.9.4',
    'rust' => 'stable',
  }

  # The rest of this file outlines classes and modules required by the dev application and CLI kit framework.
  # To understand how this works, read https://github.com/Shopify/cli-kit/blob/master/lib/cli/kit.rb

  autocall(:Executor) { CLI::Kit::Executor.new(log_file: LOG_FILE) }
  autocall(:Logger)   { CLI::Kit::Logger.new(debug_log_file: DEBUG_LOG_FILE) }

  autoload :APICommand,         'dev/api_command'
  autoload :Command,            'dev/command'
  autoload :Config,             'dev/config'
  autoload :ConfigString,       'dev/config_string'
  autoload :Context,            'dev/context'
  autoload :Dep,                'dev/dep'
  autoload :Docs,               'dev/docs'
  autoload :EntryPoint,         'dev/entry_point'
  autoload :ErrorHandler,       'dev/error_handler'
  autoload :ExceptionReporter,  'dev/exception_reporter'
  autoload :Finalize,           'dev/finalize'
  autoload :Galaxy,             'dev/galaxy'
  autoload :GlobalStateManager, 'dev/global_state_manager'
  autoload :HasGlobalState,     'dev/has_global_state'
  autoload :Metadata,           'dev/metadata'
  autoload :Project,            'dev/project'
  autoload :Resolver,           'dev/resolver'
  autoload :Stats,              'dev/stats'
  autoload :Task,               'dev/task'
  autoload :TaskEngine,         'dev/task_engine'
  autoload :Update,             'dev/update'

  # Has submodules, but autoloads them itself.
  autoload :ShellHook, 'dev/shell_hook'

  # Common helpers, with a shorter fully-qualified path, that don't feel like
  # they belong in a more verbosely-named helper below.
  autoload :Util, 'dev/util'

  module Helpers
    autoload :AddProject,               'dev/helpers/add_project'
    autoload :AndroidInstallDependency, 'dev/helpers/android_install_dependency'
    autoload :API,                      'dev/helpers/api'
    autoload :MigrationsMetricParser,   'dev/helpers/migrations_metric_parser'
    autoload :Bundler,                  'dev/helpers/bundler'
    autoload :ChrubyReset,              'dev/helpers/chruby_reset'
    autoload :CommandTracking,          'dev/helpers/command_tracking'
    autoload :Database,                 'dev/helpers/database'
    autoload :DeltaChooser,             'dev/helpers/delta_chooser'
    autoload :DidYouKnow,               'dev/helpers/did_you_know'
    autoload :DylibLinkage,             'dev/helpers/dylib_linkage'
    autoload :EaccesHandler,            'dev/helpers/eacces_handler'
    autoload :EtcHosts,                 'dev/helpers/etc_hosts'
    autoload :GCloud,                   'dev/helpers/gcloud'
    autoload :GemHelper,                'dev/helpers/gem_helper'
    autoload :Git,                      'dev/helpers/git'
    autoload :GitHookManager,           'dev/helpers/git_hook_manager'
    autoload :GithubSSH,                'dev/helpers/github_ssh'
    autoload :Growl,                    'dev/helpers/growl'
    autoload :Help,                     'dev/helpers/help'
    autoload :Homebrew,                 'dev/helpers/homebrew'
    autoload :Ini,                      'dev/helpers/ini'
    autoload :Integrations,             'dev/helpers/integrations'
    autoload :IOS,                      'dev/helpers/ios'
    autoload :Keychain,                 'dev/helpers/keychain'
    autoload :MacOS,                    'dev/helpers/mac_os'
    autoload :MaterializeRepo,          'dev/helpers/materialize_repo'
    autoload :Minikube,                 'dev/helpers/minikube'
    autoload :MultiplexMetrics,         'dev/helpers/multiplex_metrics'
    autoload :OpenGithub,               'dev/helpers/open_github'
    autoload :PackageCloud,             'dev/helpers/package_cloud'
    autoload :PidFile,                  'dev/helpers/pid_file'
    autoload :Plist,                    'dev/helpers/plist'
    autoload :PlistBuddy,               'dev/helpers/plist_buddy'
    autoload :ProcessSupervision,       'dev/helpers/process_supervision'
    autoload :RailgunSupervision,       'dev/helpers/railgun_supervision'
    autoload :PythonDep,                'dev/helpers/python_dep'
    autoload :PythonInstall,            'dev/helpers/python_install'
    autoload :Railgun,                  'dev/helpers/railgun'
    autoload :RailsDatabaseChecker,     'dev/helpers/rails_database_checker'
    autoload :RailsTemplates,           'dev/helpers/rails_templates'
    autoload :RubyDep,                  'dev/helpers/ruby_dep'
    autoload :Rubygems,                 'dev/helpers/rubygems'
    autoload :RubyInstall,              'dev/helpers/ruby_install'
    autoload :RubyLinker,               'dev/helpers/ruby_linker'
    autoload :SDHCP,                    'dev/helpers/sdhcp'
    autoload :ServerCommandInference,   'dev/helpers/server_command_inference'
    autoload :ServicesDB,               'dev/helpers/services_db'
    autoload :Shellify,                 'dev/helpers/shellify'
    autoload :Simctl,                   'dev/helpers/simctl'
    autoload :Splunk,                   'dev/helpers/splunk'
    autoload :SrcPath,                  'dev/helpers/src_path'
    autoload :Stats,                    'dev/helpers/stats'
    autoload :Submodules,               'dev/helpers/submodules'
    autoload :TableFormatter,           'dev/helpers/table_formatter'
    autoload :Template,                 'dev/helpers/template'
    autoload :Tophat,                   'dev/helpers/tophat'
    autoload :Validator,                'dev/helpers/validator'
    autoload :Version,                  'dev/helpers/version'
    autoload :Virtualenv,               'dev/helpers/virtualenv'
    autoload :Xcode,                    'dev/helpers/xcode'
  end

  module Tasks
    register :Application,                 'application',            'dev/tasks/application'
  end

  module Commands
    # Task registration is handled differently for project-local commands
    autoload :ProjectLocal, 'dev/commands/project_local'

    # See lib/dev/commands.rb
    register :CD

    Registry.add_alias('s',    'server')
  end
end
