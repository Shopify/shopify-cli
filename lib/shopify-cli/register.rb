# defines register method for files being loaded in dev.rb
module ShopifyCli
  class InvalidOverrideError < StandardError; end

  def self.invalid_register(invalid_register)
    raise InvalidOverrideError, "\n\nCannot override using `register` in `dev`."\
      "Invalid Register: #{invalid_register}\n\n"
  end
end
