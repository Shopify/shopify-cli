# defines register method for files being loaded in dev.rb
module ShopifyCli
  class InvalidOverrideError < StandardError; end

  def self.invalid_register(invalid_register)
    raise InvalidOverrideError, "\n\nCannot override using `register` in `dev`."\
      "Invalid Register: #{invalid_register}\n\n"
  end

  module Tasks
    TASKS = {}
    def self.register(const, name, path)
      Dev.invalid_register("Task: #{name} => #{path}") if TASKS[name]
      autoload(const, path)
      TASKS[name] = const
    end
  end

  module Init
    module Tasks
      TASKS = {}
      def self.register(const, name, path)
        Dev.invalid_register("Init Task: #{name} => #{path}") if TASKS[name]
        autoload(const, path)
        TASKS[name] = const
      end
    end
  end

  module TerminalCommands
    COMMANDS = {}

    def self.register(const, path)
      Dev.invalid_register("TerminalCommand: #{const} => #{path}") if COMMANDS[const]
      autoload(const, path)
      COMMANDS[const] = path
    end
  end

  module Troubleshoot
    TROUBLESHOOT = {}

    def self.register(const, path)
      Dev.invalid_register("Troubleshoot: #{const} => #{path}") if TROUBLESHOOT[const]
      autoload(const, path)
      TROUBLESHOOT[const] = path
    end

    def self.troubleshoot!(output, ctx)
      TROUBLESHOOT.any? do |const, _|
        troubleshooter = Troubleshoot.const_get(const).new(output, ctx)
        next if Array(troubleshooter.matching_output).empty?
        troubleshooter.process!
      end
    end
  end
end
