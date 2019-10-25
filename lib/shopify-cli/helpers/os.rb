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

      def uname(flag: 'a')
        @uname ||= CLI::Kit::System.capture2("uname -#{flag}")[0].strip
      end
    end
  end
end
