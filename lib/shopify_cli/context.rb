# frozen_string_literal: true
require "shopify_cli"
require "fileutils"
require "rbconfig"
require "net/http"
require "json"
require "bundler"

module ShopifyCLI
  ##
  # Context captures a lot about the current running command. It captures the
  # environment, output, system and file operations. It is useful to have the
  # context especially in tests so that you have a single access point to these
  # resoures.
  #
  class Context
    GEM_LATEST_URI = URI.parse("https://rubygems.org/api/v1/versions/shopify-cli/latest.json")
    VERSION_CHECK_SECTION = "versioncheck"
    LAST_CHECKED_AT_FIELD = "last_checked_at"
    LATEST_VERSION_FIELD = "latest_version"
    VERSION_CHECK_INTERVAL = 86400

    class << self
      attr_reader :messages

      # adds a new set of messages to be used by the CLI. The messages are expected to be a hash of symbols, and
      # multiple levels are allowed. When fetching messages a dot notation is used to separate different levels. See
      # Context::message for more information.
      #
      # #### Parameters
      # * `messages` - Hash containing the new keys to register
      def load_messages(messages)
        @messages ||= {}
        @messages = @messages.merge(messages) do |key|
          Context.new.abort("Message key '#{key}' already exists and cannot be registered") if @messages.key?(key)
        end
      end

      # returns the user-facing messages for the given key. Returns the key if no message is available.
      #
      # #### Parameters
      # * `key` - a symbol representing the message
      # * `params` - the parameters to format the string with
      def message(key, *params)
        key_parts = key.split(".").map(&:to_sym)
        str = Context.messages.dig(*key_parts)
        str ? str % params : key
      end

      # a wrapper around Kernel.puts to allow for easy formatting
      #
      # #### Parameters
      # * `text` - a string message to output
      def puts(*args)
        Kernel.puts(CLI::UI.fmt(*args))
      end

      # aborts the current running command and outputs an error message:
      # - when the `help_message` is not provided, the error message appears in
      #   a red frame, prefixed by an ✗ icon
      # - when the `help_message` is provided, the error message appears in a
      #   red frame, and the help message appears in a green frame
      #
      # #### Parameters
      # * `error_message` - an error message to output
      # * `help_message` - an optional help message
      #
      # #### Example
      #
      #   ShopifyCLI::Context.abort("Execution error")
      #   # Output:
      #   # ┏━━ Error ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      #   # ┃ ✗ Execution error
      #   # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      #
      #   ShopifyCLI::Context.abort("Execution error", "export EXECUTION=1")
      #   # Output:
      #   # ┏━━ Error ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      #   # ┃ Execution error
      #   # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      #   # ┏━━ Try this ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      #   # ┃ export EXECUTION=1
      #   # ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      #
      def abort(error_message, help_message = nil)
        raise ShopifyCLI::Abort, "{{x}} #{error_message}" if help_message.nil?

        frame(message("core.error"), color: :red) { self.puts(error_message) }
        frame(message("core.try_this"), color: :green) { self.puts(help_message) }

        raise ShopifyCLI::AbortSilent
      end

      private

      def frame(title, color:, &block)
        CLI::UI::Frame.open(title, color: CLI::UI.resolve_color(color), timing: false, &block)
      end
    end

    # is the directory root that the current command is running in. If you want to
    # simulate a `cd` for the file operations, you can change this variable.
    attr_accessor :root
    # is an accessor for environment variables. These variables are also added to
    # any command run by the context.
    attr_accessor :env

    def initialize(root: Dir.pwd, env: ($original_env || ENV).to_h) # :nodoc:
      self.root = root
      self.env = env
    end

    # will return which operating system that the cli is running on [:mac, :linux]
    def os
      host = uname
      return :mac_m1 if /arm64.*darwin/i.match(host)
      return :mac if /darwin/i.match(host)
      return :windows if /mswin|mingw|cygwin/i.match(host)
      return :linux if /linux|bsd/i.match(host)
      :unknown
    end

    # will return true if the cli is running on an ARM Apple computer.
    def mac_m1?
      os == :mac_m1
    end

    # will return true if the cli is running on a Intel x86 Apple computer.
    def mac?
      os == :mac
    end

    # will return true if the cli is running on a linux distro
    def linux?
      os == :linux
    end

    # will return true if the cli is running on Windows
    def windows?
      os == :windows
    end

    # will return true if the os is unknown
    def unknown_os?
      os == :unknown
    end

    # will return true if being launched from a tty
    def tty?
      $stdin.tty?
    end

    # will return true if the cli is being run from an installation, and not a
    # development instance. The gem installation will not have a 'test' directory.
    # See `#development?` for checking for development environment.
    #
    def system?
      !Dir.exist?(File.join(ShopifyCLI::ROOT, "test"))
    end

    # will return true if the cli is running on your development instance.
    #
    def development?
      !system? && !testing?
    end

    # will return true while tests are running, either locally or on CI
    def testing?
      ci? || ENV["SHOPIFY_CLI_TEST"]
    end

    ##
    # will return true if the cli is being tested on CI
    def ci?
      ENV["CI"]
    end

    ##
    # will return true if the cli is running with the DEBUG flag
    def debug?
      getenv("DEBUG")
    end

    # get a environment variable value by name.
    #
    # #### Parameters
    # * `name` - the name of the environment variable that you want to fetch
    #
    # #### Returns
    # * `value` - will return the value, or nil if the variable does not exist
    #
    def getenv(name)
      v = @env[name]
      v == "" ? nil : v
    end

    # set a environment variable value by name.
    #
    # #### Parameters
    # * `key` - the name of the environment variable that you want to set
    # * `value` - the value of the variable
    #
    def setenv(key, value)
      @env[key] = value
    end

    # will write/overwrite a file with the provided contents, relative to the context root
    # unless the file path is absolute.
    #
    # #### Parameters
    # * `fname` - filename of the file that you are writing, relative to root unless it is absolute.
    # * `content` - the body contents of the file that you are writing
    #
    # #### Example
    #
    #   @ctx.write('new.txt', 'hello world')
    #
    def write(fname, content)
      File.write(ctx_path(fname), content)
    end

    # will read a file relative to the context root unless the file path is absolute.
    #
    # #### Parameters
    # * `fname` - filename of the file that you are reading, relative to root unless it is absolute.
    #
    # #### Example
    #
    #   @ctx.read('file.txt')
    #
    def read(fname)
      File.read(ctx_path(fname))
    end

    # will read a binary file relative to the context root unless the file path is absolute.
    #
    # #### Parameters
    # * `fname` - filename of the file that you are reading, relative to root unless it is absolute.
    #
    # #### Example
    #
    #   @ctx.read('binary.out')
    #
    def binread(fname)
      File.binread(ctx_path(fname))
    end

    # will write/overwrite a binary file with the provided contents, relative to the context root
    # unless the file path is absolute.
    #
    # #### Parameters
    # * `fname` - filename of the file that you are writing, relative to root unless it is absolute.
    # * `content` - the body contents of the file that you are writing
    #
    # #### Example
    #
    #   @ctx.binwrite('binary.out', 'ASCII-8BIT encoded binary')
    #
    def binwrite(fname, content)
      File.binwrite(ctx_path(fname), content)
    end

    # will change directories and update the root, the filepath is relative to the command root unless absolute
    #
    # #### Parameters
    # * `path` - the file path to a directory, relative to the context root to remove from the FS
    #
    def chdir(path)
      Dir.chdir(ctx_path(path))
      self.root = ctx_path(path)
    end

    # checks if a directory exists, the filepath is relative to the command root unless absolute
    #
    # #### Parameters
    # * `path` - the file path to a directory, relative to the context root to remove from the FS
    #
    def dir_exist?(path)
      Dir.exist?(ctx_path(path))
    end

    # checks if a file exists, the filepath is relative to the command root unless absolute
    #
    # #### Parameters
    # * `path` - the file path to a file, relative to the context root to remove from the FS
    #
    def file_exist?(path)
      File.exist?(ctx_path(path))
    end

    # will recursively copy a directory from the FS, the filepath is relative to the command
    # root unless absolute
    #
    # #### Parameters
    # * `from` - the path of the original file
    # * `to` - the destination path
    #
    def cp_r(from, to)
      FileUtils.cp_r(ctx_path(from), ctx_path(to))
    end

    # will copy a directory from the FS, the filepath is relative to the command
    # root unless absolute
    #
    # #### Parameters
    # * `from` - the path of the original file
    # * `to` - the destination path
    #
    def cp(from, to)
      FileUtils.cp(ctx_path(from), ctx_path(to))
    end

    # will rename a file from one place to another, relative to the command root
    # unless the path is absolute.
    #
    # #### Parameters
    # * `from` - the path of the original file
    # * `to` - the destination path
    #
    def rename(from, to)
      File.rename(ctx_path(from), ctx_path(to))
    end

    # will remove a plain file from the FS, the filepath is relative to the command
    # root unless absolute.
    #
    # #### Parameters
    # * `fname` - the file path relative to the context root to remove from the FS
    #
    def rm(fname)
      FileUtils.rm(ctx_path(fname))
    end

    # will remove a directory from the FS, the filepath is relative to the command
    # root unless absolute
    #
    # #### Parameters
    # * `fname` - the file path to a directory, relative to the context root to remove from the FS
    #
    def rm_r(fname)
      FileUtils.rm_r(ctx_path(fname))
    end

    # will force remove a directory from the FS, the filepath is relative to the command
    # root unless absolute
    #
    # #### Parameters
    # * `fname` - the file path to a directory, relative to the context root to remove from the FS
    #
    def rm_rf(fname)
      FileUtils.rm_rf(ctx_path(fname))
    end

    # will create a directory, recursively if it does not exist. So if you create
    # a directory `foo/bar/dun`, this will also create the directories `foo` and
    # `foo/bar` if they do not exist. The path will be made relative to the command
    # root unless absolute
    #
    # #### Parameters
    # * `path` - file path of the directory that you want to create
    #
    def mkdir_p(path)
      FileUtils.mkdir_p(path)
    end

    # will output to the console a link for the user to either copy/paste
    # or click on.
    #
    # #### Parameters
    # * `uri` - a http URI to open in a browser
    #
    def open_url!(uri)
      help = message("core.context.open_url", uri)
      puts(help)
    end

    # will output to the console a link for the user to either copy/paste
    # or click on.
    #
    # #### Parameters
    # * `uri` - a http URI to open in a browser
    #
    def open_browser_url!(uri)
      if tty?
        if linux? && which("xdg-open")
          system("xdg-open", uri.to_s)
        elsif windows?
          system("start \"\" \"#{uri}\"")
        elsif mac? || mac_m1?
          system("open", uri.to_s)
        else
          open_url!(uri)
        end
      else
        open_url!(uri)
      end
    end

    # will output a message, prefixed by a yellow star, indicating that task
    # started.
    #
    # #### Parameters
    # * `text` - a string message to output
    #
    def print_task(text)
      puts "{{yellow:*}} #{text}"
    end

    # proxy call to Context.puts.
    #
    # #### Parameters
    # * `text` - a string message to output
    #
    def puts(*args)
      Context.puts(*args)
    end

    # a wrapper around $stderr.puts to allow for easy formatting
    #
    # #### Parameters
    # * `text` - a string message to output
    #
    def error(text)
      $stderr.puts(CLI::UI.fmt(text))
    end

    # a wrapper around Kernel.warn to allow for easy formatting
    #
    # #### Parameters
    # * `text` - a string message to output
    #
    def warn(*args)
      Kernel.warn(CLI::UI.fmt(*args))
    end

    # outputs a message, prefixed by a checkmark indicating that something completed
    #
    # #### Parameters
    # * `text` - a string message to output
    #
    def done(text)
      puts("{{v}} #{text}")
    end

    # proxy call to Context.abort.
    #
    # #### Parameters
    # * `error_message` - an error message to output
    # * `help_message` - an optional help message
    def abort(error_message, help_message = nil)
      Context.abort(error_message, help_message)
    end

    # outputs a message, prefixed by a red `DEBUG` tag. This will only output to
    # the console if you have `DEBUG=1` set in your shell environment.
    #
    # #### Parameters
    # * `text` - a string message to output
    #
    def debug(text)
      puts("{{red:DEBUG}} #{text}") if debug?
    end

    # proxy call to Context.message.
    #
    # #### Parameters
    # * `key` - a symbol representing the message
    # * `params` - the parameters to format the string with
    def message(key, *params)
      Context.message(key, *params)
    end

    # will grab the host info of the computer running the cli. This indicates the
    # computer architecture and operating system
    def uname
      @uname ||= RbConfig::CONFIG["host"]
    end

    # Execute a command in the user's environment
    # Outputs result of the command without capturing it
    #
    # #### Parameters
    # - `*args`: A splat of arguments evaluated as a command. (e.g. `'rm', folder` is equivalent to `rm #{folder}`)
    # - `**kwargs`: additional keyword arguments to pass to Process.spawn
    #
    # #### Returns
    # - `status`: The `Process::Status` result of the command execution.
    #
    # #### Usage
    #
    #   stat = @ctx.system('ls', 'a_folder')
    #
    def system(*args, **kwargs)
      process_status = CLI::Kit::System.system(*args, env: @env, **kwargs)
      unless process_status.success?
        abort("System call failed: #{args.join(" ")}")
      end
      process_status
    end

    # Execute a command in the user's environment
    # This is meant to be largely equivalent to backticks, only with the env passed in.
    # Captures the results of the command without output to the console
    #
    # #### Parameters
    # - `*args`: A splat of arguments evaluated as a command. (e.g. `'rm', folder` is equivalent to `rm #{folder}`)
    # - `**kwargs`: additional arguments to pass to Open3.capture2
    #
    # #### Returns
    # - `output`: output (STDOUT) of the command execution
    # - `status`: boolean success status of the command execution
    #
    # #### Usage
    #
    #   out, stat = @ctx.capture2('ls', 'a_folder')
    #
    def capture2(*args, **kwargs)
      CLI::Kit::System.capture2(*args, env: @env, **kwargs)
    end

    # Execute a command in the user's environment
    # This is meant to be largely equivalent to backticks, only with the env passed in.
    # Captures the results of the command without output to the console
    #
    # #### Parameters
    # - `*args`: A splat of arguments evaluated as a command. (e.g. `'rm', folder` is equivalent to `rm #{folder}`)
    # - `**kwargs`: additional arguments to pass to Open3.capture2e
    #
    # #### Returns
    # - `output`: output (STDOUT merged with STDERR) of the command execution
    # - `status`: boolean success status of the command execution
    #
    # #### Usage
    #
    #   out_and_err, stat = @ctx.capture2e('ls', 'a_folder')
    #
    def capture2e(*args, **kwargs)
      CLI::Kit::System.capture2e(*args, env: @env, **kwargs)
    end

    # Execute a command in the user's environment
    # This is meant to be largely equivalent to backticks, only with the env passed in.
    # Captures the results of the command without output to the console
    #
    # #### Parameters
    # - `*args`: A splat of arguments evaluated as a command. (e.g. `'rm', folder` is equivalent to `rm #{folder}`)
    # - `**kwargs`: additional arguments to pass to Open3.capture3
    #
    # #### Returns
    # - `output`: STDOUT of the command execution
    # - `error`: STDERR of the command execution
    # - `status`: boolean success status of the command execution
    #
    # #### Usage
    #
    #   out, err, stat = @ctx.capture3('ls', 'a_folder')
    #
    def capture3(*args, **kwargs)
      CLI::Kit::System.capture3(*args, env: @env, **kwargs)
    end

    # captures the info signal (ctrl-T) and provide a handler to it.
    #
    # #### Example
    #
    #   @ctx.on_siginfo do
    #     @ctx.open_url!("http://google.com")
    #   end
    #
    def on_siginfo
      # Reset any previous SIGINFO handling we had so the only action we take is the given block
      trap("INFO", "DEFAULT")

      fork do
        r, w = IO.pipe
        @signal = false
        trap("SIGINFO") do
          @signal = true
          w.write(0)
        end
        while r.read(1)
          next unless @signal
          @signal = false
          yield
        end
      rescue Interrupt
        exit(0)
      end
    end

    # Checks if the given command exists in the system
    #
    # #### Parameters
    # - `cmd`: The command to test
    #
    # #### Returns
    # The path of the executable if it is found
    #
    # @todo This is currently a duplicate of CLI::Kit::System.which() - we should make that method public when we make
    #       Kit changes and make this a wrapper instead.
    def which(cmd)
      exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
      ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(File.expand_path(path), "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end

      nil
    end

    # Checks if there's a newer version of the CLI available and returns version string if
    # this should be conveyed to the user (i.e., if it's been over 24 hours since last check)
    #
    # #### Parameters
    #
    # #### Returns
    # - `version`: string of newer version available, IFF new version is available AND it's time to inform user,
    #            : nil otherwise
    #
    def new_version
      if (time_of_last_check + VERSION_CHECK_INTERVAL) < (Time.now.to_i)
        # Fork is not supported in Windows
        if Process.respond_to?(:fork)
          fork { retrieve_latest_gem_version }
        else
          thread = Thread.new { retrieve_latest_gem_version }
          at_exit { thread.join }
        end
        latest_version =
          ShopifyCLI::Config.get(VERSION_CHECK_SECTION, LATEST_VERSION_FIELD, default: ShopifyCLI::VERSION)
        latest_version if ::Semantic::Version.new(latest_version) > ::Semantic::Version.new(ShopifyCLI::VERSION)
      end
    end

    # Returns file extension depending on OS
    # since windows has multiple extensions, the default is .exe unless otherwise specified
    #
    # #### Parameters
    # - ext: optional extension for windows file
    #
    # #### Returns
    # - ext: string for file extension on windows
    #      : empty string otherwise
    def executable_file_extension(ext = ".exe")
      if windows?
        ext
      else
        ""
      end
    end

    # Uses bundle to grab the version of a gem
    #
    # #### Parameters
    # - gem: the name of the gem to check
    #
    # #### Returns
    # - version: a Semantic::Version object with the gem version
    def ruby_gem_version(gem)
      version = Bundler.load.specs.find { |s| s.name == gem }.version
      ::Semantic::Version.new(version.to_s)
    end

    private

    def ctx_path(fname)
      require "pathname"
      if Pathname.new(fname).absolute?
        fname
      else
        File.join(root, fname)
      end
    end

    def retrieve_latest_gem_version
      response = Net::HTTP.get_response(GEM_LATEST_URI)
      latest = JSON.parse(response.body)
      ShopifyCLI::Config.set(VERSION_CHECK_SECTION, LATEST_VERSION_FIELD, latest["version"])
    rescue
      nil
    ensure
      ShopifyCLI::Config.set(VERSION_CHECK_SECTION, LAST_CHECKED_AT_FIELD, Time.now.to_i)
    end

    def time_of_last_check
      (val = ShopifyCLI::Config.get(VERSION_CHECK_SECTION, LAST_CHECKED_AT_FIELD)) ? val.to_i : 0
    end
  end
end
