module ShopifyCLI
  module Core
    # This class is just a dummy to make sure that we don't trigger warnings on the first time the updated code runs.
    # The old code would try to call the Finalizer after it is done updating, which would then trigger an autoload of
    # this class and fail.
    module Finalize
      class << self
        def deliver!
        end
      end
    end
  end
end
