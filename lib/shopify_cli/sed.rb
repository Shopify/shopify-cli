module ShopifyCLI
  class Sed
    class SedError < StandardError; end

    def replace_inline(filename, pattern, output)
      command =
        case CLI::Kit::System.os
        when :mac
          "sed -i ''"
        when :linux
          "sed -i"
        else
          raise "Unrecognized system!"
        end
      success = system("#{command} 's/#{pattern}/#{output}/' #{filename}")
      raise SedError unless success
    end
  end
end
