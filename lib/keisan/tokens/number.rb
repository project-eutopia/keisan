module Keisan
  module Tokens
    class Number < Token
      INTEGER_REGEX = /\d+/
      FLOATING_POINT_REGEX = /\d+\.\d+/
      SCIENTIFC_NOTATION_REGEX = /\d+(?:\.\d+)e(?:\+|\-)?\d+/

      REGEX = /(\d+(?:\.\d+)?(?:e(?:\+|\-)?\d+)?)/

      def self.regex
        REGEX
      end

      def value
        case string
        when SCIENTIFC_NOTATION_REGEX, FLOATING_POINT_REGEX
          Float(string)
        when INTEGER_REGEX
          Integer(string)
        end
      end
    end
  end
end
