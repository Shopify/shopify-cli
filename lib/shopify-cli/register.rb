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
      ShopifyCli.invalid_register("Task: #{name} => #{path}") if TASKS[name]
      autoload(const, path)
      TASKS[name] = const
    end
  end
end
