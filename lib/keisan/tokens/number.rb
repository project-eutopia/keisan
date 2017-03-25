module Keisan
  module Tokens
    class Number < Token
      INTEGER_REGEX = /\d+/
      FLOATING_POINT_REGEX = /\d+\.\d+/
      SCIENTIFIC_NOTATION_REGEX = /\d+(?:\.\d+)?e(?:\+|\-)?\d+/

      REGEX = /(\d+(?:\.\d+)?(?:e(?:\+|\-)?\d+)?)/

      def self.regex
        REGEX
      end

      def value
        case string
        when /\A#{SCIENTIFIC_NOTATION_REGEX}\z/, /\A#{FLOATING_POINT_REGEX}\z/
          Float(string)
        when /\A#{INTEGER_REGEX}\z/
          Integer(string)
        end
      end
    end
  end
end
