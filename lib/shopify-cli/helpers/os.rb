module ShopifyCli
  module Helpers
    module OS
      def os
        return :mac if mac?
        return :linux if linux?
      end

      def mac?
        /Darwin/.match(uname)
      end

      def linux?
        /Linux/.match(uname)
      end

      def uname
        @uname ||= CLI::Kit::System.capture2('uname -a')[0]
      end
    end
  end
end
