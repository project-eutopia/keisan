module SymbolicMath
  module Tokens
    class Operator < Token
      EXPONENT = /(?:\*\*)/
      TIMES = /(?:\*)/
      DIVIDE = /(?:\/)/
      PLUS_OR_MINUS = /(?:[\+\-]+)/
      REGEX = /(#{EXPONENT}|#{TIMES}|#{DIVIDE}|#{PLUS_OR_MINUS})/

      def self.regex
        REGEX
      end

      def operator_type
        case string
        when EXPONENT
          # Must match first to override matching against single "*"
          :^
        when TIMES
          :*
        when DIVIDE
          :/
        when PLUS_OR_MINUS
          string.count("-").even? ? :+ : :-
        end
      end
    end
  end
end
