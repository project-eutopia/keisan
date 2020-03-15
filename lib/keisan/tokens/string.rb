module Keisan
  module Tokens
    class String < Token
      def initialize(string)
        @string = string
      end

      def value
        string[1...-1]
      end
    end
  end
end
