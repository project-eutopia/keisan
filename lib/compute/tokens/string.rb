module Compute
  module Tokens
    class String < Token
      REGEX = /(\"[^\"\']*\"|\'[^\"\']*\')/

      def self.regex
        REGEX
      end

      def value
        string[1...-1]
      end
    end
  end
end
