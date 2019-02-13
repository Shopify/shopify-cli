require 'shopify-cli'

module ShopifyCli
  class Command < CLI::Kit::BaseCommand
    def initialize(*args)
      super(*args)
      @ctx ||= ShopifyCli::Context.new
    end
  end
end
