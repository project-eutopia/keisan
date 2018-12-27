module Keisan
  module Tokens
    class BitwiseShift < Operator
      LEFT_SHIFT = /(?:<<)/
      RIGHT_SHIFT = /(?:>>)/

      REGEX = /(#{LEFT_SHIFT}|#{RIGHT_SHIFT})/

      def self.regex
        REGEX
      end

      def operator_type
        case string
        when LEFT_SHIFT
          :<<
        when RIGHT_SHIFT
          :>>
        end
      end
    end
  end
end
