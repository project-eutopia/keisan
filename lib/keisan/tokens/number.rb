module Keisan
  module Tokens
    class Number < Token
      INTEGER_REGEX = /\d+/
      BINARY_REGEX = /0b[0-1]+/
      OCTAL_REGEX = /0o[0-7]+/
      HEX_REGEX = /0x[0-9a-f]+/
      FLOATING_POINT_REGEX = /\d+\.\d+/
      SCIENTIFIC_NOTATION_REGEX = /\d+(?:\.\d+)?e(?:\+|\-)?\d+/

      REGEX = /(#{BINARY_REGEX}|#{OCTAL_REGEX}|#{HEX_REGEX}|\d+(?:\.\d+)?(?:e(?:\+|\-)?\d+)?)/

      def self.regex
        REGEX
      end

      def value
        case string
        when /\A#{SCIENTIFIC_NOTATION_REGEX}\z/.freeze, /\A#{FLOATING_POINT_REGEX}\z/.freeze
          Float(string)
        else
          Integer(string)
        end
      end
    end
  end
end
