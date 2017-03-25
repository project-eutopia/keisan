module Keisan
  module Tokens
    class ArithmeticOperator < Operator
      EXPONENT = /(?:\*\*)/
      TIMES = /(?:\*)/
      DIVIDE = /(?:\/)/
      MODULO = /(?:\%)/
      PLUS_OR_MINUS = /(?:[\+\-]+)/
      REGEX = /(#{EXPONENT}|#{TIMES}|#{DIVIDE}|#{MODULO}|#{PLUS_OR_MINUS})/

      def self.regex
        REGEX
      end

      def operator_type
        case string
        when EXPONENT
          # Must match first to override matching against single "*"
          :**
        when TIMES
          :*
        when DIVIDE
          :/
        when MODULO
          :%
        when PLUS_OR_MINUS
          string.count("-").even? ? :+ : :-
        end
      end
    end
  end
end
